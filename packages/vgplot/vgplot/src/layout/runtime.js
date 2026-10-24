import { DEFAULT_SPACE_SIZE } from './defaults.js';

export function concat({ direction = 'vertical', wrap = false }, children) {
  const div = document.createElement('div');
  div.style.display = 'flex';
  div.style.flexDirection = direction === 'vertical' ? 'column' : 'row';
  div.style.flexWrap = !wrap ? 'nowrap' : wrap === true ? 'wrap' : wrap;
  div.style.justifyContent = 'flex-start';
  div.style.alignItems = 'flex-start';
  children.forEach(child => div.appendChild(child));
  Object.assign(div, { value: { element: div } });
  return div;
}

export function space({ dim = 'width', size = DEFAULT_SPACE_SIZE }) {
  const span = document.createElement('span');
  span.style.display = 'inline-block';
  span.style[dim] = Number.isNaN(+size) ? size : `${size}px`;
  return Object.assign(span, { value: { element: span } });
}
