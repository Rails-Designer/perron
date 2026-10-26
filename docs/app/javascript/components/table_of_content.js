// Usage:
//
//  <table-of-content title="On this page" items="<%%= @resource.table_of_content.to_json %>" active-classes="toc__item--highlight">
//    <template type="title">
//      <p>On this page (use this to have more controller over the title)</p>
//    </template>
//  </table-of-content>
//
class TableOfContentElement extends HTMLElement {
  constructor() {
    super();

    this.#items = JSON.parse(this.getAttribute("items"));
  }

  connectedCallback() {
    if (this.#items.length < 1) return

    this.innerHTML = this.#template;
    this.#highlightActiveLink();
  }

  // private

  #items;

  get #template() {
    return `
      <nav class="
        flex fixed top-20 right-0 flex-col gap-y-2.5 w-full max-w-[16rem] bg-white/85 border-gray-200/50 rounded-bl-md backdrop-blur-md lg:right-auto lg:top-15
        max-lg:p-2 max-lg:border-b max-lg:border-l max-lg:shadow-lg
      ">
        ${this.#leader}

        ${this.#list( { for: this.#items })}
      </nav>
    `;
  }

  #list({ for: items }) {
    if (!items?.length) return "";

    const listItems = items.map(item => `
      <li>
        <a href="#${item.id}" class="block px-3 py-1 w-full text-sm font-normal text-gray-900/80 rounded-md [ul>li>ul_&]:text-gray-600/70 hover:text-gray-900">
          ${item.text}
        </a>

        ${this.#list({ for: item.children })}
      </li>
    `).join("");

    return `<ul class="grid gap-y-0.5 [li>&]:ml-3 [li>&]:mt-1.5">${listItems}</ul>`;
  }

  #highlightActiveLink() {
    if (!this.#activeClasses) return;

    const selector = "a[href^='#']";
    const sections = [];

    this.querySelectorAll(selector).forEach(({ hash }) => {
      const element = document.getElementById(hash.slice(1));

      if (element) sections.push({ element, link: this.querySelector(`a[href="#${element.id}"]`) });
    });

    const updateActive = () => {
      let activeSection = null;

      if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight - 10) {
        activeSection = sections[sections.length - 1];
      } else {
        for (const section of sections) {
          const rect = section.element.getBoundingClientRect();

          if (rect.top <= 100) {
            activeSection = section;
          }
        }
      }

      this.querySelectorAll(selector).forEach(link => link.classList.remove(...this.#activeClasses));

      activeSection?.link?.classList.add(...this.#activeClasses);
    };

    window.addEventListener('scroll', updateActive);

    updateActive();
  }

  get #leader() {
    return this.querySelector("template[type=title]")?.innerHTML || `<p>${this.getAttribute("title") || "Table of Content"}</p>`;
  }

  get #activeClasses() {
    return this.getAttribute("active-classes")?.split(" ");
  }
}

customElements.define("table-of-content", TableOfContentElement);
