#!/usr/bin/env bash

set -e

USAGE="virustotal-scan.sh [OPTIONS]

  Options:
    --setup Start setup procedure
    --help  Show this help message"

DESCRIPTION="Uploads a file to be scanned on virustotal.com. Intended to be used as Nautilus Script"

. "../lib/parse_args.sh"
set_trap 1 2
KEYWORDS=("--setup" "-s")
parse_args _USAGE="$USAGE" _DESCRIPTION="$DESCRIPTION" "$@"

if [[ " $KW_ARGS " =~ .*(" --setup "|" -s ").* ]]
then
    echo "==========================="
    echo "== VIRUSTOTAL SCAN SETUP =="
    echo "==========================="
    echo ""
    echo "In order to use virustotal-scan.sh you need to retrieve your own, personal API key for"\
         " virustotal.com"
    echo "Follow these steps, then press [ENTER]:"
    echo ""
    echo "1. Register at https://www.virustotal.com/gui/join-us"
    echo "2. After registering and logging into Virustotal, open https://www.virustotal.com, "\
         "click on your user name/icon on the upper right and select API key. This will bring "\
         "you to the API key section in your profile."
    echo ""
    echo ""
    echo "From there, copy your API key"
    echo ""
    echo "[ENTER] to continue..."
    wait_for_enter 

fi

{
#***REMOVED***
#VT_API_KEY="<YOUR API KEY>"

setup_guide_html=\
"PGh0bWw+CiAgICA8aGVhZD4KICAgICAgICA8dGl0bGU+U2V0IHVwIHZpcnVzdG90YWwtc2Nhbi5z
aDwvdGl0bGU+CiAgICA8L2hlYWQ+CiAgICA8Ym9keT4KICAgICAgICA8aDE+U2V0IHVwIHZpcnVz
dG90YWwtc2Nhbi5zaDwvaDE+CiAgICAgICAgPHA+SW4gb3JkZXIgdG8gdXNlIHZpcnVzdG90YWwt
c2Nhbi5zaCwgeW91IG5lZWQgdG8gcmV0cmlldmUgeW91ciBvd24sIHBlcnNvbmFsIEFQSSBrZXkg
Zm9yIHZpcnVzdG90YWwuY29tLjwvcD4KICAgICAgICA8b2w+CiAgICAgICAgICAgIDxsaT4KICAg
ICAgICAgICAgICAgIFJlZ2lzdGVyIGF0IGh0dHBzOi8vd3d3LnZpcnVzdG90YWwuY29tL2d1aS9q
b2luLXVzCiAgICAgICAgICAgIDwvbGk+CiAgICAgICAgICAgIDxsaT4KICAgICAgICAgICAgICAg
IEFmdGVyIHJlZ2lzdGVyaW5nIGFuZCBsb2dnaW5nIGludG8gVmlydXN0b3RhbCwgZ28gdG8gdGhl
IDxhIGhyZWY9Imh0dHBzOi8vd3d3LnZpcnVzdG90YWwuY29tL2d1aS9ob21lIj5WaXJ1c3RvdGFs
IHN0YXJ0IHBhZ2U8L2E+LAogICAgICAgICAgICAgICAgY2xpY2sgb24geW91ciB1c2VyIG5hbWUv
aWNvbiBvbiB0aGUgdXBwZXIgcmlnaHQgYW5kIHNlbGVjdCBBUEkga2V5LiBUaGlzIHdpbGwgYnJp
bmcgeW91IHRvIHRoZSBBUEkga2V5IHNlY3Rpb24gb2YgaW4gcHJvZmlsZS48YnIvPgoKICAgICAg
ICAgICAgICAgIEZyb20gdGhlcmUsIGNvcHkgeW91ciBBUEkga2V5LgogICAgICAgICAgICA8L2xp
PgogICAgICAgICAgICA8bGk+CiAgICAgICAgICAgICAgICBPcGVuIHtTQ1JJUFRfUEFUSH0gaW4g
YSB0ZXh0IGVkaXRvciBhbmQgcmVwbGFjZSAnJmx0O1lPVVIgQVBJIEtFWSZndDsnIHdpdGggeW91
ciBBUEkga2V5LiBEb24ndCBmb3JnZXQgdG8gc2F2ZSEKCiAgICAgICAgICAgICAgICBOb3cgeW91
IGNhbiBzdGFydCB1c2luZyB2aXJ1c3RvdGFsLXNjYW4uc2ggYnkgcmlnaHQgY2xpY2tpbmcgb24g
YSBmaWxlIHdpdGhpbiBOYXV0aWx1cy4gWW91IHdpbGwgZmluZCBpdCBpbiB0aGUgY29udGV4dCBt
ZW51IHVuZGVyICdTY3JpcHRzJy4KICAgICAgICAgICAgPC9saT4KICAgICAgICA8L29sPgogICAg
PC9ib2R5Pgo8L2h0bWw+"

VT_API_KEY="$(secret-tool lookup virustotal apikey )"

if [[ $? -ne 0 ]]
then
    setup_guide_html_plain="$(echo "$setup_guide_html" | base64 -d)"
    DATA_URL="data:text/html,${setup_guide_html_plain/\{SCRIPT_PATH\}/$0}"
    notify-send -a "virustotal-scan.sh" "virustotal-scan has not been set up yet!"
    $(xdg-open "$DATA_URL" || sensible-browser "$DATA_URL" ) &
    exit 0
fi

while read -r file
do

  if [[ -d "$file" ]]
  then
    notify-send -t 15 -a "virustotal-scan" "WARN: Directories are not supported!"
  fi
  [[ -f "$file" ]] || continue

  resp="$(curl --request POST \
    --url https://www.virustotal.com/api/v3/files \
    --header "x-apikey: $VT_API_KEY" \
    --form file=@"$file")"
  id="$(echo "$resp" | jq -r ".data.id")"
  data_type="$(echo "$resp" | jq -r ".data.type")"
  
  if [[ -z "$file_id" ]] || [[ "$file_id" == "null" ]]
  then
    resp="$(curl --request GET \
    --url https://www.virustotal.com/api/v3/analyses/${id} \
    --header "x-apikey: $VT_API_KEY")"
  fi

  file_id="$(echo "$resp" | jq -r ".meta.file_info.sha256")"

  result_url="https://www.virustotal.com/gui/file/${file_id}/detection"
  notify-send -a "virustotal-scan" "Scan ready for $file: $result_url"
  xdg-open $result_url

done <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

} 2> ~/.virustotal-scan.log | tee ~/.virustotal-scan.log

