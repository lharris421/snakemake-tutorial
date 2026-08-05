#!/usr/bin/env bash
# Build every example from scratch and check that it produces what the book says
# it produces, and that a second run has nothing left to do.
#
#     bash tools/verify-examples.sh

set -uo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
fail=0

check() {  # check <description> <file>
  if [ -e "$2" ]; then
    printf '    ok       %s\n' "$2"
  else
    printf '    MISSING  %s\n' "$2"; fail=1
  fi
}

run() {  # run <dir> <cores> <expected files...>
  local dir=$1 cores=$2; shift 2
  printf '\n== %s\n' "$dir"
  cd "$ROOT/examples/$dir" || { fail=1; return; }
  rm -rf .snakemake rds out logs benchmarks build report.html

  local t0=$SECONDS
  if ! snakemake --cores "$cores" > /tmp/verify-$$.log 2>&1; then
    printf '    BUILD FAILED (see /tmp/verify-%s.log)\n' $$; fail=1; return
  fi
  printf '    built in %ss on %s cores\n' "$((SECONDS - t0))" "$cores"

  for f in "$@"; do check "$dir" "$f"; done

  if snakemake --cores "$cores" 2>&1 | grep -q "Nothing to be done"; then
    printf '    ok       second run is a no-op\n'
  else
    printf '    NOT IDEMPOTENT: second run wanted to do work\n'; fail=1
  fi
}

run 01-first-rules 2 rds/sim-naive.rds rds/sim-split.rds out/figure1.pdf
run 02-wildcards 4 out/figure1.pdf rds/sim/n400_rho80_split.rds
run 03-config 4 out/figure1.pdf rds/200/sim/n50_rho0_naive.rds
run 04-manuscript 4 out/figure1.pdf out/table1.tex build/paper.pdf \
  build/submission.pdf rds/200/sim/n50_rho0_naive.rds \
  logs/200/sim/n50_rho0_naive.log benchmarks/200/sim/n50_rho0_naive.tsv
run 05-analysis 4 rds/analysis.rds rds/models.rds rds/table1.rds \
  out/figure1.png report.html

## The claim chapter 7 makes: editing the simulation rebuilds the PDF
printf '\n== 04-manuscript: the cascade\n'
cd "$ROOT/examples/04-manuscript"
echo '## cascade check' >> code/sim.R
planned=$(snakemake -n 2>&1 | awk '/^total/ {print $2; exit}')
sed -i '' -e '/^## cascade check$/d' code/sim.R
if [ "${planned:-0}" -ge 20 ]; then
  printf '    ok       editing code/sim.R plans %s jobs, through to the PDFs\n' "$planned"
else
  printf '    UNEXPECTED: editing code/sim.R planned only %s jobs\n' "${planned:-0}"; fail=1
fi
snakemake --cores 4 > /dev/null 2>&1

printf '\n%s\n' "$([ $fail -eq 0 ] && echo 'All examples verified.' || echo 'FAILURES above.')"
exit $fail
