#!/usr/bin/env bash

if [ -z "$BIN_DIR" ] || [ -z "$INST_DIR" ] || [ -z "$BITBUCKET_HOME" ]; then
    echo "$0 is not intended to be run directly. Run start-bitbucket.sh instead"
    exit 1
fi

ES_CONFIG_PATH="$BITBUCKET_HOME/shared/search"
ES_DIR="$INST_DIR/elasticsearch"
ES_PID="$BITBUCKET_HOME/log/search/elasticsearch.pid"
ES_TMPDIR="$BITBUCKET_HOME/tmp/search"
# This version refers to <BITBUCKET_HOME>/shared/search/.version file
# Bump this version if the elasticsearch config files should be updated
ES_CONFIG_CURRENT_VERSION="3"

export ES_JVM_OPTIONS="$BITBUCKET_HOME/shared/search/jvm.options"

# Default to version 1
ES_CONFIG_VERSION="1"

# check if there is a version on the configuration directory
if [ -f "$ES_CONFIG_PATH/.version" ]; then
    ES_CONFIG_VERSION=$(cat "$ES_CONFIG_PATH/.version")
fi

# If config files are not in their appropriate location, copy them over from the templates in our distribution
if [ ! -d "$ES_CONFIG_PATH" ]; then
    echo -e "\nCopying Elasticsearch configuration to $ES_CONFIG_PATH"
    mkdir -p "$ES_CONFIG_PATH" && cp -r "$ES_DIR/config-template/"* "$ES_CONFIG_PATH"
fi

if  [ "$ES_CONFIG_VERSION" -ne "$ES_CONFIG_CURRENT_VERSION" ]; then
    mv "$ES_CONFIG_PATH/elasticsearch.yml" "$ES_CONFIG_PATH/elasticsearch.yml.bak_version2"
    mv "$ES_CONFIG_PATH/logging.yml" "$ES_CONFIG_PATH/logging.yml.bak_version2"

    cp "$ES_DIR/config-template/elasticsearch.yml" "$ES_CONFIG_PATH"
    cp "$ES_DIR/config-template/jvm.options" "$ES_CONFIG_PATH"
    cp "$ES_DIR/config-template/log4j2.properties" "$ES_CONFIG_PATH"
    echo -e "\nSetting Elasticsearch configuration to version $ES_CONFIG_CURRENT_VERSION"
    echo "$ES_CONFIG_CURRENT_VERSION" > "$ES_CONFIG_PATH/.version"
fi

if [ ! -d "$ES_TMPDIR" ]; then
    mkdir -p "$ES_TMPDIR"
    if [ $? -ne 0 ]; then
        echo "$ES_TMPDIR could not be created. Permissions issue?"
        echo "The bundled Elasticsearch was not started"
        exit 1
    fi
fi

echo -e "\nStarting bundled Elasticsearch"
echo -e "\tHint: Run start-bitbucket.sh --no-search to skip starting Elasticsearch"

# Note that Elasticsearch is always started in the background, even in "run" mode
# Set the location of Elasticsearch config directory
ES_PATH_CONF="$ES_CONFIG_PATH" ES_TMPDIR="$ES_TMPDIR" "$ES_DIR/bin/elasticsearch" -d -p "$ES_PID"
if [ $? -eq 0 ]; then
    echo "Bundled Elasticsearch started successfully"
else
    echo "There was a problem starting bundled Elasticsearch"
fi