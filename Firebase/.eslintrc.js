module.exports = {
  root: true,
  env: {
    node: true
  },
  rules: {
    // 모든 규칙 비활성화
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-unused-vars': 'off',
    'no-unused-vars': 'off',
    // 다른 모든 규칙들도 비활성화
    '@typescript-eslint/no-*': 'off'
  },
  // 전체 ESLint 기능 비활성화
  ignorePatterns: ['**/*'],
  // 간단한 구성으로 유지
  parserOptions: {
    ecmaVersion: 2020
  },
  // 모든 플러그인 비활성화
  plugins: [],
  // 모든 확장 설정 비활성화
  extends: []
};
