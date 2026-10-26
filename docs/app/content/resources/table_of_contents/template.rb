gem "importmap-rails" unless File.read("Gemfile").include?("importmap")
gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/importmap.rb")
    rails_command "importmap:install"
  end

  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

file "app/javascript/components/table_of_content.js" do
<<~"_"
// Usage:
//
//  <table-of-content title="On this page" items="<%%%%= @resource.table_of_content.to_json %%>" active-classes="toc__item--highlight">
//    <template type="title">
//      <p>On this page (use this to have more control over the title element)</p>
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
      <nav>
        ${this.#leader}

        ${this.#list( { for: this.#items })}
      </nav>
    `;
  }

  #list({ for: items }) {
    if (!items?.length) return "";

    const listItems = items.map(item => `
      <li>
        <a href="#${item.id}">
          ${item.text}
        </a>

        ${this.#list({ for: item.children })}
      </li>
    `).join("");

    return `<ul>${listItems}</ul>`;
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

_
end


create_file "app/javascript/components/index.js", <<~JS, skip: true
import "./table_of_content"
JS

application_js_path = "app/javascript/application.js"

if File.exist?(application_js_path)
  insert_into_file application_js_path, "\nimport \"components\"\n", after: /\A(?:import .+\n)*/
else
  create_file application_js_path, <<~JS
import "components"
JS
end

unless File.exist?("config/importmap.rb")
  say "Warning: importmap.rb not found!", :yellow
  say "Please set up importmap-rails first by running:"
  say "  rails importmap:install"
  say "Or use your preferred JavaScript set up."

  return
end

insert_into_file "config/importmap.rb", after: /\A.*pin .+\n+/m do
  "\npin_all_from \"app/javascript/components\", under: \"components\", to: \"components\"\n"
end
end
