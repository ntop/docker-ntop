#!/bin/bash

# ======================= RUNTIME VARIABLES =======================

# Modify these variables with your credentials.
# The GitHub credentials are not strictly necessary, if you're within 60 daily API requests limit.
# Leave empty or as default placeholders if that is the case.
# GeoIP credentials are mandatory. You need at least MaxMind GeoLite2 free account to generate license keys.
# If these are not specified here, you'd have to manually modify the /usr/local/etc/GeoIP.conf file before
# running geoipupdate to download / update database(s).
# More details here:
# https://dev.maxmind.com/geoip/geolite2-free-geolocation-data#accessing-geolite2-free-geolocation-data
GITHUB_USERNAME=your_github_username_here
GITHUB_TOKEN=your_github_token_here
GEOIP_ACCOUNT_ID=your_geoip_account_here
GEOIP_LICENSE_KEY=your_geoip_license_here

# ======================= RUNTIME CONSTANTS =======================

# Runtime constants for text formatting
RED='\033[0;31m'
RED_X='\033[0;31mx\033[0m'
GREEN='\033[0;32m'
GREEN_TICK='\033[0;32m*\033[0m'
NC='\033[0m'

# ===================== FUNCTION DECLARATIONS =====================

# FUNCTION: Download geoipupdate package from GitHub
geoip_download () {
    if [ ! -f "/$GITHUB_ASSET_FILE" ]; then
        echo "[i] Downloading file $GITHUB_ASSET_FILE";
        if wget --quiet --show-progress $GITHUB_ASSSET_URL; then
            echo -e "[${GREEN_TICK}] File downloaded.";
        else
            echo -e "[${RED_X}] Download ${RED}failed.${NC} Exiting.";
            exit 126;
        fi
    fi
}

# FUNCTION: Download checksums and validate downloaded archive file. Exit if unable to validate.
geoip_checksum () {
    if [ ! -f "/checksums-darwin-linux.txt" ]; then
        echo "[i] Downloading checksums";
        if wget --quiet --show-progress $GITHUB_XSUM_URL; then
            echo -e "[${GREEN_TICK}] File downloaded.";
            if grep -q `shasum -a 256 $GITHUB_ASSET_FILE` checksums-darwin-linux.txt; then
                echo -e "[${GREEN_TICK}] Checksum validated.";
            else
                echo -e "[${RED_X}] ${RED}Invalid${NC} checksum. ${RED}Unable${NC} to validate downloaded file. Exiting.";
                cleanup
                exit 126;
            fi
        else
            echo -e "[${RED_X}] Download ${RED}failed. Unable${NC} to validate checksums. Exiting.";
            exit 126;
        fi
    fi
}

# FUNCTION: Create missing directory structure
create_dirs () {
    if [ ! -d /usr/share/GeoIP ]; then 
        printf "[i] ";
        mkdir -pv /usr/share/GeoIP;
    fi
}

# FUNCTION: Install geoipupdate executable into recommended /usr/local/bin
install_exec () {
    # Detect if geoipupdate already installed and which version
    if [ -x "/usr/local/bin/geoipupdate" ]; then
        GEOIP_VERSION=`geoipupdate -V 2>&1 | grep -i geoipupdate | sed -e 's/geoipupdate //gi'`; fi
        # note: 2>&1 necessary, because -V outputs to stderr instead of stdout for some reason
    # No version installed => install
    if [ -z ${GEOIP_VERSION:+x} ]; then
        echo -e "[i] geoipupdate not detected or version not found. Getting it.";
    else
        # Same version installed => skip
        if [ $GITHUB_LATEST_VERSION = $GEOIP_VERSION ]; then
            echo -e "[${RED_X}] geoipupdate ${GREEN}$GITHUB_LATEST_VERSION${NC} already ${RED}installed.${NC} Skipping.";
            return 1;      
        # Other version installed => replace
        else
            echo -e "[i] Installed geoipupdate version is ${RED}$GEOIP_VERSION${NC}, will update binary to ${GREEN}$GITHUB_LATEST_VERSION${NC}.";
        fi
    fi
    geoip_download
    geoip_checksum
    echo -e "[i] Installing geoipupdate ${GREEN}$GITHUB_LATEST_VERSION${NC} executable..."
    tar -zxf $GITHUB_ASSET_FILE \
        -C /usr/local/bin --wildcards --strip-components 1 --no-anchored '*geoipupdate'
    RESULT=$?
    if [ $RESULT = "0" ]; then
        echo -e "[${GREEN_TICK}] Done.";
        return 0;
    else
        echo -e "[${RED_X}] geoipupdate executable ${RED}could not${NC} be installed. Exiting.";
        cleanup;
        exit 126;
    fi
}

# FUNCTION: install GeoIP.conf config file into recommended /usr/local/etc
install_conf () {
    if [ ! -f "/usr/local/etc/GeoIP.conf" ]; then
        echo -e "[i] GeoIP.conf config file not detected. Getting it.";
        geoip_download;
        geoip_checksum;      
        echo "[i] Installing GeoIP.conf config file...";
        tar -zxf $GITHUB_ASSET_FILE \
            -C /usr/local/etc --wildcards --strip-components 1 --no-anchored '*GeoIP.conf'
        RESULT=$?
        if [ $RESULT = "0" ]; then
            echo -e "[${GREEN_TICK}] Done.";
            modify_conf;
            return 0;
        else
            echo -e "[${RED_X}] GeoIP.conf ${RED}could not${NC} be installed. Exiting.";
            cleanup;
            exit 126;
        fi
    else
        echo -e "[${RED_X}] GeoIP.conf config file ${RED}detected$,{NC} will leave it as it is.";
    fi
}

# FUNCTION: Modify default GeoIP.conf with user credentials and recommended settings
modify_conf () {
    echo "[i] Setting up /usr/local/etc/GeoIP.conf..."
    sed -i -e '/^EditionIDs/s/$/ GeoLite2-ASN/' \
        -e '/^# DatabaseDirectory/s/^# //' \
        -e '/^DatabaseDirectory/s+/usr/local/share/GeoIP+/usr/share/GeoIP+' /usr/local/etc/GeoIP.conf
    if  [ -z ${GEOIP_ACCOUNT_ID:+x} ] || [ $GEOIP_ACCOUNT_ID = "your_geoip_account_here" ] || \
        [ -z ${GEOIP_LICENSE_KEY:+x} ] || [ $GEOIP_LICENSE_KEY = "your_geoip_license_here" ]; then
            echo -e "[${RED_X}] MaxMind GeoIP credentials ${RED}not found${NC}, manually modify /usr/local/etc/GeoIP.conf before";
            echo "downloading and updating database.";
    else
            echo -e "[${GREEN_TICK}] MaxMind GeoIP credentials found, modifying /usr/local/etc/GeoIP.conf...";
            sed -i -e "/AccountID/s/YOUR_ACCOUNT_ID_HERE/$GEOIP_ACCOUNT_ID/" \
                -e "/^LicenseKey/s/YOUR_LICENSE_KEY_HERE/$GEOIP_LICENSE_KEY/"  /usr/local/etc/GeoIP.conf

    fi
}

# FUNCTION: Cleanup - remove temporary files
cleanup () {
    echo "[i] Cleaning up..."
    if [ -a $GITHUB_ASSET_FILE ]; then rm $GITHUB_ASSET_FILE; fi
    if [ -a github_api.json ]; then rm github_api.json; fi
    if [ -a checksums-darwin-linux.txt ]; then rm checksums-darwin-linux.txt; fi
    echo -e "[${GREEN_TICK}] Done."
}

# =========================== MAIN CODE ===========================

# Install dependencies for the script. curl (GitHub API calls), wget (download repo),
# tar (unpack x.tar.gz), jq (JSON parser) and nano (config/script editing)
echo "[i] Installing few script dependencies if needed (curl, wget, tar, jq, nano)..."
apt-get -qq install curl wget tar jq nano &>/dev/null
RESULT=$?
if [ $RESULT = "0" ]; then
    echo -e "[${GREEN_TICK}] Dependencies installed.";
else
    echo -e "[${RED_X}] Dependencies ${RED}could not${NC} be installed. Script wouldn't work. Exiting.";
    exit 126;
fi

# Detect system architecture to select correct GitHub asset download
SYS_ARCH=`uname -sm`
case $SYS_ARCH in
    "Linux aarch64" | "Linux armv8b" | "Linux armv8l")
        DL_ARCH="linux_arm64"
        ;;
    "Linux armv7l" | "Linux armv6l")
        DL_ARCH="linux_armv6"
        ;;
    "Linux x86_64")
        DL_ARCH="linux_amd64"
        ;;
    "Linux i386" | "Linux i686")
        DL_ARCH="linux_386"
        ;;
    "Darwin arm64")
        DL_ARCH="darwin_arm64"
        ;;
    "Darwin x86_64")
        DL_ARCH="darwin_amd64"
        ;;
    *)
        echo -e "[${RED_X}] Supported system architecture ${RED}not detected.${NC} Exiting."
        exit 126
        ;;
esac
echo -e "[${GREEN_TICK}] Detected system architecture is ${GREEN}$SYS_ARCH${NC}"

# Get the latest repo release assets info from GitHub's API
if  [ -z ${GITHUB_USERNAME:+x} ] || [ $GITHUB_USERNAME = "your_github_username_here" ] || \
    [ -z ${GITHUB_TOKEN:+x} ] || [ $GITHUB_TOKEN = "your_github_token_here" ]; then
        echo -e "[${RED_X}] GitHub credentials ${RED}not found${NC}, using rate limited API call...";
        curl --fail --silent -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/maxmind/geoipupdate/releases/latest > github_api.json;
        RESULT=$?;
else
        echo -e "[${GREEN_TICK}] GitHub credentials found, using authenticated API call...";
        curl --fail --silent -u $GITHUB_USERNAME:$GITHUB_TOKEN -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/maxmind/geoipupdate/releases/latest > github_api.json;
        RESULT=$?;
fi
if [ $RESULT = "0" ]; then
    echo -e "[${GREEN_TICK}] GitHub connected. Repo JSON captured.";
else
    echo -e "[${RED_X}] GitHub ${RED}could not${NC} be contacted. Exiting.";
    cleanup;
    exit 126;
fi

# Parse resulting JSON through jq tool and assign results to variables to facilitate download
GITHUB_LATEST_VERSION=`jq -r '.name' < github_api.json`
GITHUB_ASSSET_URL=`jq -r '.assets[].browser_download_url | scan(".*_'$DL_ARCH'.tar.gz")' < github_api.json`
GITHUB_ASSET_FILE=`jq -r '.assets[].name | scan(".*_'$DL_ARCH'.tar.gz")' < github_api.json`
GITHUB_XSUM_URL=`jq -r '.assets[].browser_download_url | scan(".*checksums-darwin-linux.txt")' < github_api.json`

echo -e "[i] Latest ${GREEN}$SYS_ARCH${NC} version of maxmillian/updategeoip on GitHub is: ${GREEN}$GITHUB_LATEST_VERSION${NC}"

# Initial info established, let's get installing
install_exec
install_conf
create_dirs
cleanup

# All required components in place, run geoipupdate
echo "[i] Running geoipupdate to download / update database files..."
geoipupdate
RESULT=$?
if [ $RESULT = "0" ]; then
    echo -e "[${GREEN_TICK}] GeoIP database(s) downloaded / updated.";
    # Install cron job to run update database automatically
    echo "[i] Creating geoipupdate cron job - run update twice weekly (Mon, Thu) at 22:55";
    echo "55 22 * * 1,4 /usr/local/bin/geoipupdate" > /etc/cron.d/root;
    echo -e "[${GREEN_TICK}] Finished.";
else
    echo -e "[${RED_X}] GeoIP database(s) ${RED}could not${NC} be downloaded. Check config.";
fi
