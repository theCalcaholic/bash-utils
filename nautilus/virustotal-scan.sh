#!/usr/bin/env bash

set -x

{

VT_API_KEY="<YOUR API KEY>"

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

if [[ "$VT_API_KEY" == "<YOUR API KEY>" ]]
then
    setup_guide_html_plain="$(echo "$setup_guide_html" | base64 -d)"
    DATA_URL="data:text/html,${setup_guide_html_plain/\{SCRIPT_PATH\}/$0}"
    notify-send -a "virustotal-scan.sh" "virustotal-scan has not been set up yet!" "<a href=\"$DATA_URL\">Configure it now</a>"
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
  notify-send -a "virustotal-scan" "Scan ready for $file: $result_url" \
  || xdg-open $result_url

done <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

} 2> ~/.virustotal-scan.log | tee ~/.virustotal-scan.log

