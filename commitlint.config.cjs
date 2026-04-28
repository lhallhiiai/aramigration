// commitlint configuration for Conventional Commits per CLAUDE.md.
// The wagoid/commitlint-github-action workflow loads this file from the
// repo root and validates every commit in the PR against it.
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // CLAUDE.md allowed types — extends conventional with `data` and `infra`,
    // drops conventional-only types we do not use (build, ci, perf, revert).
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'data',
        'infra',
        'refactor',
        'test',
        'docs',
        'chore',
        'style',
      ],
    ],
    // CLAUDE.md: first line must be 72 characters or less.
    'header-max-length': [2, 'always', 72],
    // CLAUDE.md: "description is lowercase" — interpreted as "subject must
    // not be Title Case / Sentence case", not "no uppercase letters
    // anywhere." Acronyms like ARA, CLIN, JAMIS, SQL, API are allowed.
    // This matches the @commitlint/config-conventional default.
    'subject-case': [
      2,
      'never',
      ['sentence-case', 'start-case', 'pascal-case', 'upper-case'],
    ],
    'subject-full-stop': [2, 'never', '.'],
  },
};
