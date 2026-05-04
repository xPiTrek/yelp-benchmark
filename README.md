# Yelp Benchmark: MySQL vs PostgreSQL on Amazon RDS

Benchmarking MySQL 8 and PostgreSQL 16 across local and Amazon RDS deployments using the Yelp Academic Dataset (23+ million records).


## Overview

This project compares MySQL and PostgreSQL performance using sysbench with custom SQL queries adapted from the [ronaldbradford/benchmark](https://github.com/ronaldbradford/benchmark) framework. Tests cover read performance, write performance, concurrency scaling (1–50 threads), read replica horizontal scaling, and vertical scaling across RDS instance sizes.

## Dataset

| Table | Rows |
|-------|------|
| yelp_business | 150,346 |
| yelp_user | 1,987,897 |
| yelp_review | ~6.9M |
| yelp_tip | 908,915 |
| yelp_checkin | 13,356,875 |
| **Total** | **23,394,280** |

Source: [Yelp Open Dataset](https://www.yelp.com/dataset)

## Settings

- **Local:** MacBook Air M2, 8 GB RAM, MySQL 8.x + PostgreSQL 16.x
- **RDS:** db.t3.medium (2 vCPU, 4 GB RAM), gp3 storage (3,000 IOPS), us-east-2c
- **EC2 Client:** t3.medium, Amazon Linux 2023
- **Tool:** sysbench 1.0.20

## Files

| File | Description |
|------|-------------|
| `core.lua` | Main sysbench Lua script (from ronaldbradford/benchmark) |
| `oltp_common.lua` | sysbench OLTP common library |
| `business.sql` | Read queries (PK lookup, JOIN, aggregate) parameterized by business_id |
| `user.sql` | Read queries parameterized by user_id |
| `business_write.sql` | Mixed read/write queries (SELECT, UPDATE, DELETE) |
| `business.txt` | 500 random business_ids for parameterized queries |
| `user.txt` | 500 random user_ids for parameterized queries |
| `business_write.txt` | Business_ids for write benchmark |
| `run_benchmarks.sh` | Automated benchmark runner for all databases |
| `.gitignore` | Excludes config files with database credentials |

## How to Run

```bash
# Install sysbench
brew install sysbench  # Mac

# Generate parameter data files
mysql -u root benchmarkdb -N -e "SELECT business_id FROM yelp_business ORDER BY RAND() LIMIT 500;" > business.txt
mysql -u root benchmarkdb -N -e "SELECT user_id FROM yelp_user ORDER BY RAND() LIMIT 500;" > user.txt
cp business.txt business_write.txt

# Create config file (copy example below, fill in your credentials)
# db-driver=mysql (or pgsql)
# mysql-host=127.0.0.1
# mysql-port=3306
# mysql-user=your_user
# mysql-password=your_password
# mysql-db=benchmarkdb
# threads=4
# time=60
# report-interval=10

# Run benchmark
sysbench core.lua --config-file=your-config.cnf --type=business run
sysbench core.lua --config-file=your-config.cnf --type=user run
sysbench core.lua --config-file=your-config.cnf --type=business_write run
```

## References

- [ronaldbradford/benchmark](https://github.com/ronaldbradford/benchmark) — Benchmark framework
- [jOOQ SQL Benchmark](https://www.jooq.org/benchmark) — Methodology reference
- [AWS MySQL vs PostgreSQL](https://aws.amazon.com/compare/the-difference-between-mysql-vs-postgresql/) — Claims tested
- [sysbench](https://github.com/akopytov/sysbench) — Benchmarking tool
- [Yelp Dataset](https://www.kaggle.com/datasets/yelp-dataset/yelp-dataset/code) — Data source
