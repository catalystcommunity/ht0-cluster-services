import yaml
import sys
import os

# File paths we'll be working with
PLATFORM_SERVICES_TEMPLATE=os.environ.get("PLATFORM_SERVICES_TEMPLATE")
PLATFORM_SERVICES_FILE=os.environ.get("PLATFORM_SERVICES_FILE")
PROMETHEUS_TEMPLATE=os.environ.get("PROMETHEUS_TEMPLATE")
PROMETHEUS_FILE=os.environ.get("PROMETHEUS_FILE")

# The replacements we'll be making
PLATFORM_REPLACEMENTS = {
    'cloudflareApiEmail': os.environ.get('CLOUDFLARE_API_EMAIL'),
    'cloudflareApiToken': os.environ.get('CLOUDFLARE_API_TOKEN'),
    'grafanaDatasourceCortexPassword': os.environ.get('GRAFANA_CORTEXT_PASSWORD'),
    'grafanaDatasourceLokiPassword': os.environ.get('GRAFANA_LOKI_PASSWORD'),
    'grafanaAdminPassword': os.environ.get('GRAFANA_ADMIN_PASSWORD'),
    'grafanaNotifierCatalystCommunityAlerts': os.environ.get('CATALYST_COMMUNITY_ALERTS_URL'),
    'linkerdIssuerKeyPEM': os.environ.get('LINKERD_ISSUER_KEY_PEM'),
    'promtailBasicAuthPassword': os.environ.get('PROMTAIL_PASS'),
}
PROMETHEUS_REPLACEMENTS = {
    'clusterName': os.environ.get('CLUSTER_NAME'),
}


def replace_value_in_file(input_file_path, output_file_path, replacement_dict):
    with open(input_file_path, "r") as file:
        lines = file.readlines()

    with open(output_file_path, "w") as file:
        for line in lines:
            for key, value in replacement_dict.items():
                if key in line.strip():
                    indent = line[: len(line) - len(line.lstrip())]
                    new_lines = [indent + new_line for new_line in value.split("\n")]
                    line = "\n".join(new_lines) + "\n"
            file.write(line)

def validate_yaml(file_path):
    try:
        with open(file_path, "r") as file:
            yaml.safe_load(file)
        return True
    except yaml.YAMLError:
        return False

def main():
    validSetup = True
    if None in list(PLATFORM_REPLACEMENTS.values()) + list(PROMETHEUS_REPLACEMENTS.values()):
        print("Error: Missing environment variables.")
        validSetup = False
        for key, value in PLATFORM_REPLACEMENTS.items() + PROMETHEUS_REPLACEMENTS.items():
            if value is None:
                print(f"Missing expected environent variable value for template key: {key}")
    # This is just stupid and ugly, but we're doing it since this is just a CI script
    if None in [PLATFORM_SERVICES_TEMPLATE, PLATFORM_SERVICES_FILE, PROMETHEUS_TEMPLATE, PROMETHEUS_FILE]:
        print("Error: Missing environment variables.")
        for key, value in {
            "PLATFORM_SERVICES_TEMPLATE": PLATFORM_SERVICES_TEMPLATE,
            "PLATFORM_SERVICES_FILE": PLATFORM_SERVICES_FILE,
            "PROMETHEUS_TEMPLATE": PROMETHEUS_TEMPLATE,
            "PROMETHEUS_FILE": PROMETHEUS_FILE,
        }.items():
            if value is None:
                print(f"Missing value for {key}")
                validSetup = False

    if not validSetup:
        sys.exit(1)

    replace_value_in_file(PLATFORM_SERVICES_TEMPLATE, PLATFORM_SERVICES_FILE, PLATFORM_REPLACEMENTS)
    replace_value_in_file(PROMETHEUS_TEMPLATE, PROMETHEUS_FILE, PROMETHEUS_REPLACEMENTS)

    if not validate_yaml(PLATFORM_SERVICES_FILE):
        print(
            f"Error: The file {PLATFORM_SERVICES_FILE} is not valid YAML after replacements."
        )
        sys.exit(1)
    if not validate_yaml(PROMETHEUS_FILE):
        print(
            f"Error: The file {PROMETHEUS_FILE} is not valid YAML after replacements."
        )
        sys.exit(1)

if __name__ == "__main__":
    main()