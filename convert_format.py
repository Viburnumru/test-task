import argparse
import os
import sys
import logging
import time

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
    return allele1, allele2  # надо добавить, тут я считаю что allele1 = ref


def process_file(input_file, output_file):
    if not os.path.exists(input_file):
        logging.error(f"Файл {input_file} не найден.")
        sys.exit(1)

    try:
        with open(input_file, "r", encoding="utf-8") as infile, open(
            output_file, "w", encoding="utf-8"
        ) as outfile:
            header = infile.readline().strip().split("\t")
            expected_header = ["#CHROM", "POS", "ID", "allele1", "allele2"]

            if header != expected_header:
                logging.error("Неверный формат заголовка входного файла.")
                sys.exit(1)

            outfile.write("#CHROM\tPOS\tID\tREF\tALT\n")

            for line in infile:
                line = line.strip()
                if not line:
                    continue
                columns = line.split("\t")
                if len(columns) != 5:
                    logging.warning(
                        f"Пропуск строки из-за неверного формата: {line}"
                    )
                    continue

                chrom, pos, snp_id, allele1, allele2 = columns
                ref, alt = detect_ref_alt(chrom, pos, allele1, allele2)
                outfile.write(f"{chrom}\t{pos}\t{snp_id}\t{ref}\t{alt}\n")

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
