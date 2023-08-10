
#!/usr/bin/env bash

DESCRIPTION="Script to rund the flatpak version of nvim and give it arbitrary permissions for the target (file or directory) path"

USAGE="fp-nvim-launcher.sh target-path"

set -e
##### parse_args.sh #####
source <(echo 'H4sICI9WLWAAA3BhcnNlX2FyZ3Muc2gApVZtc5tGEP7Or1ifsWWpg2W5ky9S5VipGNeTqd1I9iQdRWWQOCFqBMoBkRJL/e3ZOzg4AYk7LTMScLv77N5z+8LxUTuJWHvmBW0afIaZHS01zbLeDMa/DUY3Y2tovnm86WuaS2Mr/rKmlrew6NaL4uisCc+aBuCHc9sHLoN5EucLDp0lbp/oZSyCGpMJGF+B6EKHwHQKux3Q+TIEUvUD+jWBq9NLQEP+8xbcnujPndd7Av0+kKeNYbMU5/RUCEF/fmv++f5+NBxPWtM9LvT/gfMWX79EqzPSIzsCpHneQiPEjJc04PB8BxjzgTEPmPpVr4G9ok6N45H57vF2ZA7/g+OKNYoWnpZv2ggwAtQk9VHj7bjFPe1F0D/kGaBzDjths98JfoWF3KZwgqH/hQHLWBWHIM4783lyAq3M4QsuL4VLbqr6LMD4/bjV+3dgP9eCIV0vWqZWXSOKmRe4+8JYKAiSSxpCymicsAAu8kP5oZMgjGERJoEj4TPzjsDS9pq2tllELUygtJQAjtPKeaJfNiFzov4ZMYw1C/+mczwMfGbU9cJAPH4NAyoeVvZ86QXU4PGS5mE50u0aTamTr0bLMPEda42biq0l9dd9srD9iMqa5DuXqS/349C5bzMKhg1SpGjLdK3RliLUzle3Axfevrd4Nygv3w1+N4dVie2CWOOkhwyQLfC442sesxNqStaKgOSeSU3OyuQWXIkaRh5k9R5BTKMYpaKiDfpJPl5eQduhn9tB4vsyXwvMLGmIORrdj7pgZu7BhiBZzSiDWRKDi7nQ4GiNI1KyK97TU0ki26WFztaL4ZUskyy3QVI4UbY77afhatIwXe/nDtIaS9/ydmZZj+PBjZmSoWe9rL7U01Ko4qcAZdihOf51dPvHw+393f8BV2EKF1m7OKuZFekoyNw1ycsZMAtDP4+rdLIFzRwNGY5ZQvMgsW6Uc5IRq4eQnZeiKf0LMrh7w+BlKKunJFt+LzD1LPlVU9dqqGm3KvxXKvf7PmpJziefCtMswilKeaIolDIU8gaBfU6Ze9fTbmcvOlmFZY74E9cWh3tIsrg52BW1g4+ECjMptYKd0hBNdRwazZm3jrHRFiMho7pcoaI6L5TPgzpiFVIPOsXDkmJH8/1wg5mPw+FT4jHeN5ibrGiALPP+t/KiCMXdww+Dk14xb6tdI+0ZnWxKiUFT6GSTRsYiirdLlBU+HWXeC+m0a5Bf7kIQ5rCikbiLyXZFMIwcX2Gu5KVAVOpZ4ipmh6gRTzxmrzMw/ggESW6A3sI//Dj5qL/OmvezPKeeSkgPcLabH24fxLjd2F5s4QyxkF3K8hA3S8+nwBNCvOJIkenGqO2AEYFxBx0wYvzDyZxLZYbhmsgpvfFxe2E3imoq1RO/Zgj51MuXstQVWbvXvgGMInk7igsAAA==' | base64 -d | gunzip -cq)
#########################
#KEYWORDS=("-b" "--backup" "-c" "--command")
REQUIRED=("target-path")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
set_trap 1 2

target_path="$(realpath "${NAMED_ARGS['target-path']}")"

keepass_cmd_pattern='flatpak run --file-forwarding org.keepassxc.KeePassXC @@ "--DB_PATH--" @@'
keepass_cmd_pattern="${KW_ARGS["-c"]-$keepass_cmd_pattern}"
keepass_cmd_pattern="${KW_ARGS["--command"]-$keepass_cmd_pattern}"


export FLATPAK_ENABLE_SDK_EXT="typescript,rust-stable,rust-nightly,php82,openjdk17,openjdk,node18,llvm16,golang"

args=(--env=PATH="/app/bin:/usr/bin:$HOME/.cargo/bin" --filesystem="${target_path}" io.neovim.nvim "${target_path}")
flatpak run --user "${args[@]}" 2> >(grep -v 'app/io.neovim.nvim/x86_64/stable not installed' >&2) \
    || flatpak run "${args[@]}"

