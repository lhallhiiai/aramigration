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
    // CLAUDE.md: description is lowercase, no period at the end.
    'subject-case': [2, 'always', 'lower-case'],
    'subject-full-stop': [2, 'never', '.'],
  },
};
