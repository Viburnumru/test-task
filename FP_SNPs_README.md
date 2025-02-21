# Скрипт преобразования форматов SNP

Скрипт предназначен для преобразования файла из формата с двумя аллеями в формат с референсным и альтернативным аллеем. 
Он работает с файлами, содержащими данные SNP и их позицию на хромосомах (см. пример в /Examples).
Формат входного файла: #CHROM POS ID allele1 allele2


В случае исходного формата данных в виде: rs#     chromosome      GB37_position   GB38_position   allele1 allele2
необходимо привести исходный файл к указанному формату с помощью, например, команды:

```bash
awk 'BEGIN {OFS="\t"; print "#CHROM", "POS", "ID", "allele1", "allele2"} 
     NR > 1 && $2 != "23" {print "chr"$2, $4, "rs"$1, $5, $6}' FP_SNPs.txt > FP_SNPs_10k_GB38_twoAllelsFormat.tsv
```
Далее будем работать с файлом FP_SNPs_10k_GB38_twoAllelsFormat.tsv.

Формат выходного файла: #CHROM POS ID REF ALT
Где:
- `REF` — референсный аллель
- `ALT` — альтернативный аллель

## Установка

Для работы с этим скриптом необходимо наличие Python 3, а также библиотеки pysam, pandas, samtools. 
Окружение сохранено в requirements.txt. 


## Подготовка референсного генома
Структура репозитория должна соответствовать
```
project/
├── convert_format.py
├── examples/
│   ├── FP_SNP_Converted.tsv
│   └── FP_SNP_Converted_output.tsv
└── ref/
    └── GRCh38.d1.vd1_mainChr/
        └── sepChrs/
            ├── chr1.fa
            ├── chr1.fa.fai
            ├── chr2.fa
            ├── chr2.fa.fai
            └── ...
```
Пример команды для создания индексов с помощью samtools:
```bash
samtools faidx GRCh38.d1.vd1.fa
```
Пример команды для извлечения хромосом:

```bash
for chr in {1..22} M X Y; do
    samtools faidx GRCh38.d1.vd1.fa chr$chr > chr$chr.fa
done
```

Пример команды для индексации хромосом: 
```bash
for chr in {1..22} M X Y; do
    samtools faidx chr$chr.fa
done
```

## Использование

1. Скачайте или клонируйте репозиторий с этим скриптом.
2. Запустите скрипт с параметрами из командной строки:

```bash
python3 convert_format.py -i input_file.txt -o output_file.txt
```

справка:
```bash
python3 convert_format.py --h
```

Можно проверить работу скрипта вручную, пример команды:
```bash
samtools faidx 1.fa chr1:1220751-1220751
```

Output:
```bash
>chr1:1220751-1220751
T
```

В случае отсутствия аллеля в референсном геноме ошибка запишется в файл convert_format.log в следующем формате:

```
2025-02-21 01:37:22,911 - WARNING - Ошибка при обработке строки: {'CHROM': 'chr1', 'POS': 145899155, 'ID': 'rs2274617', 'allele1': 'T', 'allele2': 'C'}. Ошибка: Несовпадение аллелей: T, C != G на позиции chr1:145899155
```

