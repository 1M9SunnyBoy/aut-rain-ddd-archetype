#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 配置 TypeScript 与 React Hooks 静态检查规则。
 * author: zzy
 * created: 2026-10-19
 */
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import hooks from "eslint-plugin-react-hooks";
import globals from "globals";
export default tseslint.config(
    { ignores: ["dist/**", "node_modules/**"] },
    js.configs.recommended,
    ...tseslint.configs.recommended,
    {
        files: ["**/*.{ts,tsx}"],
        languageOptions: { globals: globals.browser },
        plugins: { "react-hooks": hooks },
        rules: { ...hooks.configs.recommended.rules },
    },
);
