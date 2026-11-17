# Вариант 1 - наземный сегмент управления спутниками ДЗЗ

Паттерн: георезервирование станций + failover dep-a -> dep-b.
Отказ в эксперименте: dep-a недоступна (503), `FAULT='{"down": true}'`. R = 3 реплики app.

| Файл | Что | Кто |
|---|---|---|
| core.py | каркас преподавателя + паттерн в `do_work()` | B |
| test_core.py | 7 тестов паттерна без кластера | B |
| metrics.py | POFOD, ROCOF, AVAIL, p50/p95/p99 по CSV | A |
| test_metrics.py | проверка metrics.py на примере из 20 запросов | A |
| fair_mc.py | FAIR: PERT и Монте-Карло (задание 5) | A |
| dep.py, loadgen.py, stand.yaml, load-job.yaml, experiment.sh | даны преподавателем, без изменений | - |
| run_local.sh | тот же эксперимент без Kubernetes | - |
| results/off.csv, results/on.csv | результаты прогонов (заменить на Killercoda) | вместе |

## Тесты
    python3 -m unittest -v

## Killercoda (Kubernetes Playground)
    git clone <репозиторий> && cd <папка>
    kubectl create configmap code --from-file=dep.py --from-file=core.py --from-file=loadgen.py
    kubectl apply -f stand.yaml
    kubectl get pods                 # все Running, READY 1/1
    chmod +x experiment.sh
    export FAULT='{"down": true}'
    ./experiment.sh off
    ./experiment.sh on

## Параметры паттерна (env в stand.yaml или kubectl set env deployment/app ...)
- TIMEOUT_S (0.5) - сколько ждем dep-a
- FAILBACK_S (10) - сколько не обращаемся к dep-a после отказа
