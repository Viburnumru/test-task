# test-task

Docker контейнер позволяет осуществить установку программ: 
## Установленные программы:
- samtools 1.21.
- htslib 1.21
- bcftools 1.18
- vcftools 0.1.16
- скрипт convert_format.py
  
## Сборка Docker-образа
```bash
docker build -t test-task .
```
Для использования:
```
docker run -it test-task
```
Для проверки работы установки программ внутри контейнера:
```
samtools --version
bcftools --version
vcftools --help
```
или
```
$SAMTOOLS --version
$BCFTOOLS --version
$VCFTOOLS --help
```
