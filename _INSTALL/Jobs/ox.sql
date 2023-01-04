USE `overextended`;

INSERT INTO `ox_groups` (
    `name`,
    `label`,
    `grades`,
    `hasAccount`,
    `adminGrade`,
    `colour`
  )
VALUES (
    'taxi',
    'Downtown Cab Co.',
    '["Recruit", "Driver", "Lead Driver", "Owner"]',
    b'0',
    4,
    NULL
  );