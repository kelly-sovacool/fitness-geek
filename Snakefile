import datetime
import pathlib

today = datetime.datetime.today()
years = range(2017, datetime.datetime.today().year+1)
filename_raw_csv = "data/raw/activities.csv"
csv_path = pathlib.Path(filename_raw_csv)

# forcerun download rule if the raw data file was last modified before today
if csv_path.exists():
    timestamp = datetime.datetime.fromtimestamp(csv_path.stat().st_mtime)
    if today > timestamp:
        csv_path.touch(exist_ok=True)

rule targets:
    output:
        "docs/report.html"

rule download:
    input:
        R="code/download.R"
    output:
        csv=filename_raw_csv
    script:
        "{input.R}"

rule process:
    input:
        R="code/process_raw_data.R",
        csv=rules.download.output.csv
    output:
        csv="data/processed/activities.csv"
    script:
        "{input.R}"

rule plot:
    input:
        R="code/make_plots.R",
        csv=rules.process.output.csv
    output:
        line_plot="figures/line_all.png",
        bar_plot="figures/bar_all.png",
        bar_years=expand("figures/bar_{year}.png", year=years)
    params:
        years=years
    script:
        "{input.R}"

rule render_report:
    input:
        R="code/render.R",
        plots=rules.plot.output
    output:
        "docs/report.html"
    script:
        "{input.R}"
