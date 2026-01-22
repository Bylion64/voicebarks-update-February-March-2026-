import {
  CheckboxInput,
  type Feature,
  FeatureNumberInput,
  type FeatureNumeric,
  type FeatureToggle,
} from '../../base';

export const starting_fatness: Feature<number> = {
  name: 'Starting Fatness',
  description: 'How fat is your character when starting the round?',
  component: FeatureNumberInput,
};

export const weight_gain_rate: FeatureNumeric = {
  name: 'Weight Gain Rate',
  description: 'How quickly do you get fat?',
  component: FeatureNumberInput,
};

export const weight_loss_rate: FeatureNumeric = {
  name: 'Weight Loss Rate',
  description: 'How quickly do you lose fat?',
  component: FeatureNumberInput,
};

export const max_weight: Feature<number> = {
  name: 'Maximum Weight',
  description:
    'What is the maximum weight we want our character to be at? 0 means there will be no weight cap.',
  component: FeatureNumberInput,
};

export const weight_gain_persistent: FeatureToggle = {
  name: 'Persistent weight',
  description:
    'Endround/cryo weight becomes your new start weight. This will override your starting fatness.',
  component: CheckboxInput,
};

export const weight_gain_permanent: FeatureToggle = {
  name: 'Permanent weight',
  description: 'Persists between round, hard to remove.',
  component: CheckboxInput,
};

export const severe_fatness_penalty: FeatureToggle = {
  name: 'Severe fatness penalties',
  description:
    'Toggle if you want your character to be SIGNIFICANTLY affected by fattening mechanics, some of which may be persistent between rounds.',
  component: CheckboxInput,
};

export const safe_bursting: FeatureToggle = {
  name: 'Safe bursting',
  description:
    'Toggle if you want your character to be unharmed after bursting. Basically putting them back into a non inflated state.',
  component: CheckboxInput,
};

export const see_bursting: FeatureToggle = {
  name: 'See bursting',
  description: 'Toggle if you want to see people bursting by inflation.',
  component: CheckboxInput,
};
