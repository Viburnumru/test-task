import argparse
import os
import sys
import logging
import time
import pysam
import pandas as pd

REFERENCE_GENOME_DIR = os.getenv(
    "REFERENCE_GENOME_DIR", "./ref/GRCh38.d1.vd1_mainChr/sepChrs/"
)

log_filename = "convert_format.log"
logging.basicConfig(
    filename=log_filename,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Скрипт преобразует файл из формата '#CHROM\tPOS\tID\tallele1\tallele2' в формат '#CHROM\tPOS\tID\tREF\tALT'."
    )
    parser.add_argument(
        "-i", "--input", required=True, help="Путь к входному файлу"
    )
    parser.add_argument(
        "-o", "--output", required=True, help="Путь к выходному файлу"
    )
    return parser.parse_args()


def detect_ref_alt(chrom, pos, allele1, allele2):
    if not chrom.startswith("chr"):
        chrom = f"chr{chrom}"

    fasta_file = os.path.join(REFERENCE_GENOME_DIR, f"{chrom}.fa")
    fai_file = fasta_file + ".fai"

    if not os.path.exists(fasta_file):
        raise FileNotFoundError(
            f"FASTA-файл для хромосомы {chrom} не найден: {fasta_file}"
        )
    if not os.path.exists(fai_file):
        raise FileNotFoundError(
            f"Индексный файл для хромосомы {chrom} не найден: {fai_file}"
        )

    fasta = pysam.FastaFile(fasta_file)
    ref_allele = fasta.fetch(chrom, pos - 1, pos).upper()

    if allele1.upper() == ref_allele:
        return allele1, allele2
    elif allele2.upper() == ref_allele:
        return allele2, allele1
    else:
        raise ValueError(
            f"Несовпадение аллелей: {allele1}, {allele2} != {ref_allele} на позиции {chrom}:{pos}"
        )


def process_file(input_file, output_file):
    if not os.path.exists(input_file):
        logging.error(f"Файл {input_file} не найден.")
        sys.exit(1)

    try:
        df = pd.read_csv(
            input_file,
            sep="\t",
            comment="#",
            header=None,
            names=["CHROM", "POS", "ID", "allele1", "allele2"],
        )

        results = []
        for _, row in df.iterrows():
            chrom = "chr" + row["CHROM"].replace("chr", "")
            pos = row["POS"]
            snp_id = row["ID"]
            allele1 = row["allele1"]
            allele2 = row["allele2"]

            try:
                ref, alt = detect_ref_alt(chrom, pos, allele1, allele2)
                results.append((chrom, pos, snp_id, ref, alt))
            except ValueError as e:
                logging.warning(
                    f"Ошибка при обработке строки: {row.to_dict()}. Ошибка: {e}"
                )
                continue

        result_df = pd.DataFrame(
            results, columns=["CHROM", "POS", "ID", "REF", "ALT"]
        )

        result_df.to_csv(output_file, sep="\t", index=False)

        logging.info(
            f"Обработка завершена. Результат сохранен в {output_file}"
        )
    except Exception as e:
        logging.error(f"Ошибка при обработке файла: {e}")
        sys.exit(1)


if __name__ == "__main__":
    start_time = time.time()
    args = parse_arguments()
    process_file(args.input, args.output)
    logging.info(f"Время выполнения: {time.time() - start_time:.2f} сек")
