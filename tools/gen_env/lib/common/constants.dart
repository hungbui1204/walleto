import 'flavor_model.dart';

const flavorKey = 'FLAVOR';
const launchJsonPath = '.vscode/launch.json';
const workspaceXmlPath = '.idea/workspace.xml';

const flavorsList = [
  Flavor(
    flavorEnum: FlavorsEnum.development,
    name: 'development',
    prefix: 'DEV',
    envPath: './env/development.json',
  ),
  Flavor(
    flavorEnum: FlavorsEnum.staging,
    name: 'staging',
    prefix: 'STG',
    envPath: './env/staging.json',
  ),
  Flavor(
    flavorEnum: FlavorsEnum.production,
    name: 'production',
    prefix: 'PROD',
    envPath: './env/production.json',
  ),
];
