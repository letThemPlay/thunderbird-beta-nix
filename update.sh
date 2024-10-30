locales=("en-GB" "en-US" "fr" )
content=$(curl https://product-details.mozilla.org/1.0/thunderbird_versions.json)
version=$(jq -r '.LATEST_THUNDERBIRD_DEVEL_VERSION' <<< "$content")

sources=()

for locale in ${locales[@]}; do
  url=https://releases.mozilla.org/pub/thunderbird/releases/$version/linux-x86_64/$locale/thunderbird-$version.tar.bz2
  hash=$(nix-prefetch-url $url)
  sources+=( $(jo url=$url arch="linux-x86_64" locale=$locale sha256=$hash))
done
final=$(jo -p version=$version sources=$(jo -a ${sources[@]}))
echo $final > beta-sources.json
