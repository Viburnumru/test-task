# Скрипт преобразования форматов SNP

Скрипт предназначен для преобразования файла из формата с двумя аллеями в формат с референсным и альтернативным аллеем. 
Он работает с файлами, содержащими данные SNP и их позицию на хромосомах (см. пример в /Examples).
Формат входного файла: #CHROM POS ID allele1 allele2


В случае исходного формата данных в виде: rs#     chromosome      GB37_position   GB38_position   allele1 allele2
необходимо привести исходный файл к указанному формату с помощью:
```bash
awk 'BEGIN {OFS="\t"; print "#CHROM", "POS", "ID", "allele1", "allele2"} 
     NR > 1 && $2 != "23" {print "chr"$2, $4, "rs"$1, $5, $6}' FP_SNPs.txt > FP_SNPs_10k_GB38_twoAllelsFormat.tsv
```
Далее работать с файлом FP_SNPs_10k_GB38_twoAllelsFormat.tsv.

Формат выходного файла: #CHROM POS ID REF ALT
Где:
- `REF` — референсный аллель
- `ALT` — альтернативный аллель (allele2).

## Установка

Для работы с этим скриптом необходимо наличие Python 3. 

## Использование

1. Скачайте или клонируйте репозиторий с этим скриптом.
2. Запустите скрипт с параметрами командной строки:

```bash
python3 convert_format.py -i input_file.txt -o output_file.txt
```

справка:
```bash
python3 convert_format.py --h
```

