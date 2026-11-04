#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 验证起始页面的可见标题。
 * author: zzy
 * created: 2026-10-19
 */
import { render, screen } from '@testing-library/react';
import { expect, it } from 'vitest';
import App from './App';

it('renders the generated landing page', () => {
  render(<App />);
  expect(screen.getByRole('heading', { name: '项目已生成' })).toBeInTheDocument();
});
