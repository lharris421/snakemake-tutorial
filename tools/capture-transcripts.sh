#!/usr/bin/env bash
# Regenerate every terminal transcript shown in the book by actually running the
# commands.  Run from the repository root:
#
#     bash tools/capture-transcripts.sh
#
# Output goes to transcripts/.  Two things are filtered out of the raw snakemake
# output: the "Assuming unrestricted shared filesystem usage" / "host:" preamble,
# which is noise, and the PULP_CBC_CMD warning, which reflects a broken ILP solver
# in some snakemake installations and is discussed in chapter 9 rather than
# repeated in every transcript.

# Note: deliberately no `set -e`.  Several of these commands are supposed to
# fail (chapter 9 is about error messages), and snakemake exits non-zero on a
# dry run that finds nothing to do.
set -uo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
OUT="$ROOT/transcripts"
mkdir -p "$OUT"

clean() {  # remove everything a run regenerates, including this example's
           # slice of the central results folder
  rm -rf .snakemake out logs benchmarks build report.html
  rm -rf "$ROOT/results/$(basename "$PWD")"
}

filter() {
  grep -vE '^(Assuming unrestricted|host:|Failed to solve scheduling|Complete log\(s\)|Building DAG)' |
    sed -e 's/^\[.*\]$//' |
    cat -s
}

say() { printf '$ %s\n' "$1"; }

# snakemake prints the job stats table twice on a dry run (once before the plan,
# once after); keep only the first
first_stats() { awk '/^Job stats:/{f=1} f{print} /^total/{if (f) exit}'; }

## ---------------------------------------------------------------- example 01
cd "$ROOT/examples/01-first-rules"
clean

{ say "snakemake -n"; snakemake -n 2>&1 | filter; } > "$OUT/01-dry-run.txt"
{ say "snakemake --cores 2"; snakemake --cores 2 2>&1 | filter; } > "$OUT/01-run.txt"
{ say "snakemake --cores 2"; snakemake --cores 2 2>&1 | filter; } > "$OUT/01-up-to-date.txt"
{
  say "rm out/figure1.pdf"
  rm out/figure1.pdf
  say "snakemake --cores 2"
  snakemake --cores 2 2>&1 | filter
} > "$OUT/01-rebuild-figure.txt"

## ---------------------------------------------------------------- example 02
cd "$ROOT/examples/02-wildcards"
clean

{ say "snakemake -n"; snakemake -n 2>&1 | filter | first_stats; } \
  > "$OUT/02-job-stats.txt"
{
  say "snakemake --cores 1 ../../results/02-wildcards/sim/n50_rho0_naive.rds"
  snakemake --cores 1 ../../results/02-wildcards/sim/n50_rho0_naive.rds 2>&1 | filter
} > "$OUT/02-one-target.txt"
{ say "snakemake --cores 4"; snakemake --cores 4 2>&1 | filter | tail -20; } \
  > "$OUT/02-run-tail.txt"

## ---------------------------------------------------------------- example 03
cd "$ROOT/examples/03-config"
clean

{
  say "snakemake --cores 4 --config iterations=20"
  { time snakemake --cores 4 --config iterations=20 > /dev/null 2>&1 ; } 2>&1
  say "snakemake --cores 4 --forcerun sim"
  { time snakemake --cores 4 --forcerun sim > /dev/null 2>&1 ; } 2>&1
} > "$OUT/03-smoke-vs-full.txt"

## ---------------------------------------------------------------- example 04
cd "$ROOT/examples/04-manuscript"
clean
snakemake --cores 4 > /dev/null 2>&1

{
  say "touch code/sim.R && snakemake -n"
  touch code/sim.R
  snakemake -n 2>&1 | filter | tail -3
} > "$OUT/04-touch-is-not-enough.txt"

{
  say "echo '## a real edit' >> code/sim.R && snakemake -n"
  echo '## a real edit' >> code/sim.R
  snakemake -n 2>&1 | filter | first_stats
} > "$OUT/04-cascade.txt"

{
  say "snakemake -n out/figure1.pdf"
  snakemake -n out/figure1.pdf 2>&1 | filter |
    sed -n '/^rule figure1:/,/^$/p' | head -7
} > "$OUT/04-reason.txt"

# put sim.R back and rebuild so the checked-out example is consistent
sed -i '' -e '/^## a real edit$/d' code/sim.R
snakemake --cores 4 > /dev/null 2>&1

{ say "cat benchmarks/sim/n400_rho80_naive.tsv"; cat benchmarks/sim/n400_rho80_naive.tsv; } \
  > "$OUT/04-benchmark.txt"
{ say "cat logs/sim/n400_rho80_naive.log"; cat logs/sim/n400_rho80_naive.log; } \
  > "$OUT/04-log.txt"

# The book shows this generated file, and results/ is not committed, so keep a
# copy next to the transcripts for the same reason
cp out/table1.tex "$OUT/table1.tex"

## ---------------------------------------------------------------- example 05
cd "$ROOT/examples/05-analysis"
clean

{ say "snakemake --cores 4"; snakemake --cores 4 2>&1 | filter | first_stats; } \
  > "$OUT/05-job-stats.txt"
{ say "cat logs/clean.log"; cat logs/clean.log; } > "$OUT/05-clean-log.txt"
{ say "cat logs/model.log"; cat logs/model.log; } > "$OUT/05-model-log.txt"

## ---------------------------------------------------- errors, for chapter 09
cd "$ROOT/examples/02-wildcards"
{
  say "snakemake --cores 1 out/coverage-summary.csv"
  snakemake --cores 1 out/coverage-summary.csv 2>&1 | filter | head -8
} > "$OUT/09-missing-rule.txt"

{
  say "snakemake --cores 1 ../../results/02-wildcards/sim/n50_rho0_bayes.rds"
  snakemake --cores 1 ../../results/02-wildcards/sim/n50_rho0_bayes.rds 2>&1 | filter | tail -14
} > "$OUT/09-job-failed.txt"
rm -f ../../results/02-wildcards/sim/n50_rho0_bayes.rds

cd "$ROOT/examples/04-manuscript"
{
  say "snakemake --summary | head -6"
  snakemake --summary 2>&1 | filter | head -6
} > "$OUT/09-summary.txt"

{
  say "snakemake --list"
  snakemake --list 2>&1 | filter
} > "$OUT/09-list.txt"

echo "transcripts written to $OUT"
