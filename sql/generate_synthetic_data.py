#!/usr/bin/env python3
"""
Generador de datos sinteticos para NotariaJuridica.

Uso:
  python generate_synthetic_data.py                    # imprime SQL a stdout
  python generate_synthetic_data.py -o synthetic.sql   # guarda script SQL
  python generate_synthetic_data.py --execute        # ejecuta via sqlcmd

Requiere scripts 01-04 ya aplicados en la instancia SQL Server.
"""

from __future__ import annotations

import argparse
import random
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

NOMBRES = [
    "Carlos", "Maria", "Jose", "Ana", "Luis", "Patricia", "Roberto", "Laura",
    "Fernando", "Gabriela", "Ricardo", "Silvia", "Alberto", "Claudia",
]
APELLIDOS = [
    "Garcia", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",
    "Perez", "Sanchez", "Ramirez", "Torres", "Flores", "Rivera",
]
EMPRESAS = [
    "Inmobiliaria Horizonte SA de CV",
    "Servicios Legales del Centro SC",
    "Constructora Metropolitana SA",
    "Comercializadora Azteca SA de CV",
    "Desarrollos Urbanos del Pacifico SA",
]
COLONIAS = ["Centro", "Del Valle", "Reforma", "Narvarte", "Polanco", "Coyoacan"]
OBS_EXP = [
    "Compraventa de inmueble residencial",
    "Constitucion de sociedad mercantil",
    "Poder general para pleitos y cobranzas",
    "Contrato de arrendamiento comercial",
    "Protocolizacion de acta de asamblea",
]
ESTADOS_TRAMITE = ["PENDIENTE", "EN_PROCESO", "FIRMADO", "CERRADO", "CANCELADO"]
ESTADOS_EXP = ["ABIERTO", "EN_TRAMITE", "CERRADO", "ARCHIVADO"]
TIPOS_DOC = ["ACTA", "CONTRATO", "ANEXO", "OTRO"]
TIPOS_ACTA = ["Comparecencia", "Identificacion", "Asamblea"]


@dataclass
class GenConfig:
    num_clientes: int = 40
    expedientes_min: int = 1
    expedientes_max: int = 3
    tramites_min: int = 1
    tramites_max: int = 2
    docs_min: int = 1
    docs_max: int = 3
    versiones_max: int = 3
    pct_firma: float = 0.85
    pct_respaldo: float = 0.60
    folio_base: int = 10000
    anio: str = "2026"
    seed: int | None = 42


def esc(value: str) -> str:
    return value.replace("'", "''")


def nv(value: str) -> str:
    return "N'" + esc(value) + "'"


def gen_cliente(seq: int, cfg: GenConfig) -> dict:
    if random.random() < 0.25:
        tipo = "JURIDICA"
        nombre = random.choice(EMPRESAS)
        ident = f"RFC-PY{cfg.folio_base + seq:08d}"
    else:
        tipo = "FISICA"
        nombre = f"{random.choice(NOMBRES)} {random.choice(APELLIDOS)} {random.choice(APELLIDOS)}"
        ident = f"CURP-PY{cfg.folio_base + seq:08d}"
    return {
        "tipo_persona": tipo,
        "nombre_razon": nombre,
        "identificacion": ident,
        "correo": f"cliente.py{cfg.folio_base + seq}@notaria.demo",
        "telefono": f"555{random.randint(1000000, 9999999)}",
        "direccion": f"Calle {random.randint(100, 999)}, Col. {random.choice(COLONIAS)}, CDMX",
    }


def build_sql(cfg: GenConfig) -> str:
    if cfg.seed is not None:
        random.seed(cfg.seed)

    lines: list[str] = [
        "/* Generado por generate_synthetic_data.py */",
        "SET NOCOUNT ON;",
        "USE NotariaJuridica;",
        "GO",
        "",
        "DECLARE @id_notario INT = 1;",
        "DECLARE @id_secretario INT = 2;",
        "DECLARE @id_admin INT = 3;",
        "DECLARE @cert VARCHAR(80) = 'CERT-NOT-001';",
        "",
    ]

    folio_seq = cfg.folio_base
    acta_seq = cfg.folio_base
    doc_seq = 0

    for c in range(1, cfg.num_clientes + 1):
        cl = gen_cliente(c, cfg)
        lines.append(
            "INSERT INTO notaria.Cliente (tipo_persona, nombre_razon, identificacion, correo, telefono, direccion) "
            f"VALUES ('{cl['tipo_persona']}', {nv(cl['nombre_razon'])}, '{cl['identificacion']}', "
            f"'{cl['correo']}', '{cl['telefono']}', {nv(cl['direccion'])});"
        )
        lines.append("DECLARE @id_cliente INT = SCOPE_IDENTITY();")

        num_exp = random.randint(cfg.expedientes_min, cfg.expedientes_max)
        for _ in range(num_exp):
            folio_seq += 1
            folio = f"EXP-{cfg.anio}-{folio_seq:05d}"
            obs = random.choice(OBS_EXP)
            lines.extend([
                "DECLARE @id_exp INT;",
                "EXEC notaria.sp_AbrirExpediente",
                f"    @id_cliente = @id_cliente,",
                f"    @folio_expediente = '{folio}',",
                "    @id_usuario = @id_secretario,",
                f"    @observaciones = {nv(obs)},",
                "    @id_expediente = @id_exp OUTPUT;",
            ])

            num_tram = random.randint(cfg.tramites_min, cfg.tramites_max)
            for t in range(num_tram):
                tipo_tram = random.randint(1, 3)
                estado = random.choice(ESTADOS_TRAMITE)
                desc = f"Tramite sintetico tipo {tipo_tram} - {folio}"
                lines.extend([
                    "INSERT INTO notaria.Tramite (id_expediente, id_tipo_tramite, descripcion, estado)",
                    f"VALUES (@id_exp, {tipo_tram}, {nv(desc)}, '{estado}');",
                    "DECLARE @id_tram INT = SCOPE_IDENTITY();",
                ])

                num_docs = random.randint(cfg.docs_min, cfg.docs_max)
                for d in range(num_docs):
                    doc_seq += 1
                    tipo_doc = random.choice(TIPOS_DOC)
                    titulo = f"{tipo_doc} - {folio} - doc {d + 1}"
                    ruta = f"\\\\archivo\\\\{cfg.anio}\\\\{folio}\\\\doc_{doc_seq}.pdf"
                    lines.extend([
                        "INSERT INTO notaria.Documento (id_tramite, tipo_documento, titulo, ruta_archivo)",
                        f"VALUES (@id_tram, '{tipo_doc}', {nv(titulo)}, {nv(ruta)});",
                        "DECLARE @id_doc INT = SCOPE_IDENTITY();",
                    ])

                    if tipo_doc == "ACTA":
                        acta_seq += 1
                        num_acta = f"ACTA-{cfg.anio}-{acta_seq:05d}"
                        tipo_acta = random.choice(TIPOS_ACTA)
                        lines.append(
                            "INSERT INTO notaria.Acta (id_documento, numero_acta, tipo_acta, lugar_celebracion) "
                            f"VALUES (@id_doc, '{num_acta}', {nv(tipo_acta)}, N'Notaria 15, CDMX');"
                        )

                    if tipo_doc == "CONTRATO":
                        monto = random.randint(10_000, 5_000_000)
                        lines.append(
                            "INSERT INTO notaria.Contrato (id_documento, monto, moneda, vigencia_inicio) "
                            f"VALUES (@id_doc, {monto}.00, 'MXN', CAST(GETDATE() AS DATE));"
                        )

                    num_ver = random.randint(1, cfg.versiones_max)
                    firmar_ultima = random.random() <= cfg.pct_firma
                    for v in range(1, num_ver + 1):
                        contenido = f"Contenido sintetico doc {doc_seq} v{v} {folio}"
                        resumen = f"Version {v} de {titulo}"
                        lines.extend([
                            "DECLARE @id_ver INT;",
                            "DECLARE @hash VARBINARY(MAX) = CONVERT(VARBINARY(MAX), " + nv(contenido) + ");",
                            "EXEC notaria.sp_RegistrarVersionDocumento",
                            "    @id_documento = @id_doc,",
                            f"    @contenido_resumen = {nv(resumen)},",
                            "    @contenido_hash = @hash,",
                            "    @id_usuario = @id_secretario,",
                            "    @id_version = @id_ver OUTPUT;",
                        ])
                        if v < num_ver or firmar_ultima:
                            lines.extend([
                                "DECLARE @id_firma INT;",
                                "EXEC notaria.sp_AplicarFirmaElectronica",
                                "    @id_version = @id_ver,",
                                "    @id_usuario = @id_notario,",
                                "    @certificado_serial = @cert,",
                                "    @id_firma = @id_firma OUTPUT;",
                            ])

            if random.random() <= cfg.pct_respaldo:
                lines.extend([
                    "DECLARE @id_resp INT;",
                    "DECLARE @chk VARBINARY(MAX) = CONVERT(VARBINARY(MAX), " + nv(f"Respaldo {folio}") + ");",
                    "EXEC notaria.sp_EjecutarRespaldoExpediente",
                    "    @id_expediente = @id_exp,",
                    f"    @ruta_respaldo = {nv(f'\\\\backup\\\\{cfg.anio}\\\\06\\\\{folio}.zip')},",
                    "    @checksum_entrada = @chk,",
                    "    @id_usuario = @id_admin,",
                    "    @observaciones = N'Respaldo sintetico Python',",
                    "    @id_respaldo = @id_resp OUTPUT;",
                ])

            estado_exp = random.choice(ESTADOS_EXP)
            lines.append(f"UPDATE notaria.Expediente SET estado = '{estado_exp}' WHERE id_expediente = @id_exp;")
            lines.append("")

    lines.extend([
        "SELECT 'Clientes' AS entidad, COUNT(*) AS total FROM notaria.Cliente",
        "UNION ALL SELECT 'Expedientes', COUNT(*) FROM notaria.Expediente",
        "UNION ALL SELECT 'Tramites', COUNT(*) FROM notaria.Tramite",
        "UNION ALL SELECT 'Documentos', COUNT(*) FROM notaria.Documento",
        "UNION ALL SELECT 'Versiones', COUNT(*) FROM notaria.VersionDocumento",
        "UNION ALL SELECT 'Firmas', COUNT(*) FROM notaria.FirmaElectronica",
        "UNION ALL SELECT 'Auditorias', COUNT(*) FROM notaria.Auditoria",
        "UNION ALL SELECT 'Respaldos', COUNT(*) FROM notaria.Respaldo;",
        "GO",
    ])
    return "\n".join(lines) + "\n"


def execute_sql(sql_path: Path, server: str) -> int:
    cmd = ["sqlcmd", "-S", server, "-E", "-i", str(sql_path), "-b"]
    return subprocess.call(cmd)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generador de datos sinteticos NotariaJuridica")
    parser.add_argument("-o", "--output", type=Path, help="Archivo SQL de salida")
    parser.add_argument("--execute", action="store_true", help="Ejecutar via sqlcmd")
    parser.add_argument("--server", default=r"(localdb)\MSSQLLocalDB", help="Instancia SQL Server")
    parser.add_argument("--clientes", type=int, default=40)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    cfg = GenConfig(num_clientes=args.clientes, seed=args.seed)
    sql = build_sql(cfg)

    if args.output:
        args.output.write_text(sql, encoding="utf-8")
        print(f"SQL generado: {args.output}", file=sys.stderr)
        out_path = args.output
    else:
        out_path = Path(__file__).parent / "_synthetic_output.sql"
        out_path.write_text(sql, encoding="utf-8")
        print(sql)

    if args.execute:
        target = args.output or out_path
        print(f"Ejecutando en {args.server}...", file=sys.stderr)
        return execute_sql(target, args.server)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())