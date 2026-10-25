import { coordinator, isParam, MosaicClient } from '@uwdata/mosaic-core';

/**
 * Instantiate an input, register it with the coordinator, and
 * return the corresponding HTML element.
 * @template {new (...args: any) => Input<import('@uwdata/mosaic-core').SelectionExpression>} T
 * @param {T} InputClass
 * @param {ConstructorParameters<T>} params
 * @returns {HTMLElement} The container element of the input.
 */
export function input(InputClass, ...params) {
  const owner = coordinator();
  const input = new InputClass(...params, owner.nativeContext ?? undefined);
  owner.connect(input);
  return input.element;
}

/**
 * Base class for input components.
 * @import {Activatable} from '@uwdata/mosaic-core'
 * @template {import('@uwdata/mosaic-core').SelectionExpression} [E=import('@uwdata/mosaic-sql').ExprNode]
 * @extends {MosaicClient<E>}
 * @implements {Activatable}
 */
export class Input extends MosaicClient {
  /**
   * Create a new input instance.
   * @param {import('@uwdata/mosaic-core').Selection<E>} [filterBy] A selection
   *  with which to filter backing data that parameterizes this input.
   * @param {HTMLElement} [element] Optional container HTML element to use.
   * @param {string} [className] A class name to set on the container element.
   * @param {object} [sqlOwner] The internal native SQL pilot context.
   */
  constructor(filterBy, element, className = 'input', sqlOwner) {
    super(filterBy, sqlOwner);
    this.element = element || document.createElement('div');
    if (className) this.element.setAttribute('class', className);
    Object.defineProperty(this.element, 'value', { value: this });
  }

  activate() {
    // subclasses should override
  }

  _bindSource(source) {
    if (isParam(source)) {
      this._sourceParam = source;
      this._sourceListener = () => this.initialize();
      source.addEventListener('value', this._sourceListener);
    }
  }

  destroy() {
    this._sourceParam?.removeEventListener('value', this._sourceListener);
    super.destroy();
  }
}
