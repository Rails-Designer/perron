class ScrollableScreenshot extends HTMLElement {
  connectedCallback() {
    const image = this.querySelector('img');
    if (!image) return;

    image.addEventListener('load', () => this.#configureScroll(image));
    this.#configureScroll(image);
  }

  #configureScroll(image) {
    const scrollDistance = image.offsetHeight - this.offsetHeight;
    if (scrollDistance <= 0) return;

    const duration = getComputedStyle(this).getPropertyValue('--scroll-duration') || '6s';
    image.style.transition = `transform ${duration} linear`;

    this.addEventListener('mouseenter', () => {
      image.style.transform = `translateY(-${scrollDistance}px)`;
    });

    this.addEventListener('mouseleave', () => {
      image.style.transition = 'transform 0.4s ease-out';
      image.style.transform = 'translateY(0)';
    });
  }
}

customElements.define('scrollable-screenshot', ScrollableScreenshot);
