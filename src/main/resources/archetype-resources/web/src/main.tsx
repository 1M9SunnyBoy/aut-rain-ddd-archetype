#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 挂载 React 应用并加载组件库和全局样式。
 * author: zzy
 * created: 2026-10-19
 */
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import 'antd/dist/reset.css';
import App from './App';
import './styles.css';

// index.html 提供唯一 root 节点；开发时启用 StrictMode 帮助发现副作用问题。
createRoot(document.getElementById('root')!).render(<StrictMode><App /></StrictMode>);
