gem "importmap-rails" unless File.read("Gemfile").include?("importmap")
gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/importmap.rb")
    rails_command "importmap:install"
  end

  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  create_file "app/javascript/components/index.js", <<~JS, skip: true
  import "components/embed_content"
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
    "\npin_all_from \"app/javascript/components\", under: \"components\"\npin_all_from \"app/javascript/helpers\", under: \"helpers\"\n"
  end

  create_file "app/javascript/components//embed_content.js", <<~'TEXT', force: true
export class EmbedContent extends HTMLElement {
  static get observedAttributes() {
    return ["src", "last-read-at", "limit"]
  }

  connectedCallback() {
    this.#connectToggle()

    this.#fetch()
  }

  async refresh() {
    await this.#fetch()
  }

  show() {
    const items = this.querySelector("[items]")

    if (items) items.removeAttribute("hidden")
  }

  hide() {
    const items = this.querySelector("[items]")

    if (items) items.setAttribute("hidden", "")
  }

  toggle() {
    const items = this.querySelector("[items]")
    if (!items) return

    items.hasAttribute("hidden") ? items.removeAttribute("hidden") : items.setAttribute("hidden", "")
  }

  // private

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue === newValue) return

    if (name === "last-read-at") this.#markUnread()
  }

  #connectToggle() {
    const button = this.querySelector("button[toggle]")
    if (!button) return

    button.addEventListener("click", () => this.toggle())
  }

  async #fetch() {
    const src = this.getAttribute("src")
    if (!src) return

    this.setAttribute("loading", "")

    try {
      const response = await fetch(src)
      const items = await response.json()

      this.#render(items)
      this.#markUnread()
      this.removeAttribute("loading")
    } catch (error) {
      this.setAttribute("error", "")
    }
  }

  #render(items) {
    const container = this.querySelector("[items]")
    if (!container) return

    const limit = parseInt(this.getAttribute("limit"), 10)
    const limited = limit > 0 ? items.slice(0, limit) : items

    container.innerHTML = limited.map((item) => this.template(item)).join("")
  }

  #markUnread() {
    const lastReadAt = this.getAttribute("last-read-at")
    const items = this.querySelectorAll("[published-at]")

    if (!lastReadAt) {
      items.forEach((item) => {
        item.removeAttribute("unread")
      })

      this.removeAttribute("total-unread")

      return
    }

    const lastRead = new Date(lastReadAt).getTime()
    let totalUnread = 0

    items.forEach((item) => {
      const published = new Date(item.getAttribute("published-at")).getTime()

      if (published > lastRead) {
        item.setAttribute("unread", "")

        totalUnread++
      } else {
        item.removeAttribute("unread")
      }
    })

    if (totalUnread > 0) {
      this.setAttribute("total-unread", totalUnread)
    } else {
      this.removeAttribute("total-unread")
    }

    this.#syncBadge()
  }

  #syncBadge() {
    const badge = this.querySelector("[badge]")
    if (!badge) return

    badge.textContent = this.getAttribute("total-unread") || ""
  }

  get template() {
    return (item) => `
      <li published-at="${item.published_at}">
        <h3><a href="${item.url}">${item.title}</a></h3>

        <p>${item.body}</p>
      </li>
    `
  }
}

customElements.define("embed-content", EmbedContent)

TEXT

create_file "app/javascript/components//index.js", <<~'TEXT', force: true
import "components/embed-content"

TEXT

create_file "app/javascript/components/embed_content.js", <<~'TEXT', force: true
export class EmbedContent extends HTMLElement {
  static get observedAttributes() {
    return ["src", "last-read-at", "limit"]
  }

  connectedCallback() {
    this.#connectToggle()

    this.#fetch()
  }

  async refresh() {
    await this.#fetch()
  }

  show() {
    const items = this.querySelector("[items]")

    if (items) items.removeAttribute("hidden")
  }

  hide() {
    const items = this.querySelector("[items]")

    if (items) items.setAttribute("hidden", "")
  }

  toggle() {
    const items = this.querySelector("[items]")
    if (!items) return

    items.hasAttribute("hidden") ? items.removeAttribute("hidden") : items.setAttribute("hidden", "")
  }

  // private

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue === newValue) return

    if (name === "last-read-at") this.#markUnread()
  }

  #connectToggle() {
    const button = this.querySelector("button[toggle]")
    if (!button) return

    button.addEventListener("click", () => this.toggle())
  }

  async #fetch() {
    const src = this.getAttribute("src")
    if (!src) return

    this.setAttribute("loading", "")

    try {
      const response = await fetch(src)
      const items = await response.json()

      this.#render(items)
      this.#markUnread()
      this.removeAttribute("loading")
    } catch (error) {
      this.setAttribute("error", "")
    }
  }

  #render(items) {
    const container = this.querySelector("[items]")
    if (!container) return

    const limit = parseInt(this.getAttribute("limit"), 10)
    const limited = limit > 0 ? items.slice(0, limit) : items

    container.innerHTML = limited.map((item) => this.template(item)).join("")
  }

  #markUnread() {
    const lastReadAt = this.getAttribute("last-read-at")
    const items = this.querySelectorAll("[published-at]")

    if (!lastReadAt) {
      items.forEach((item) => {
        item.removeAttribute("unread")
      })

      this.removeAttribute("total-unread")

      return
    }

    const lastRead = new Date(lastReadAt).getTime()
    let totalUnread = 0

    items.forEach((item) => {
      const published = new Date(item.getAttribute("published-at")).getTime()

      if (published > lastRead) {
        item.setAttribute("unread", "")

        totalUnread++
      } else {
        item.removeAttribute("unread")
      }
    })

    if (totalUnread > 0) {
      this.setAttribute("total-unread", totalUnread)
    } else {
      this.removeAttribute("total-unread")
    }

    this.#syncBadge()
  }

  #syncBadge() {
    const badge = this.querySelector("[badge]")
    if (!badge) return

    badge.textContent = this.getAttribute("total-unread") || ""
  }

  get template() {
    return (item) => `
      <li published-at="${item.published_at}">
        <h3><a href="${item.url}">${item.title}</a></h3>

        <p>${item.body}</p>
      </li>
    `
  }
}

customElements.define("embed-content", EmbedContent)

TEXT
end
