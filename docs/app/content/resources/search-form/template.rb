gem "importmap-rails" unless File.read("Gemfile").include?("importmap")
gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/importmap.rb")
    rails_command "importmap:install"
  end

  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  route "resource :search, module: :perron, path: \"search.json\", only: %%w[show]"

  insert_into_file "config/initializers/perron.rb", "\n  config.search_scope = []\n", after: "Perron.configure do |config|"

  create_file "app/javascript/components/index.js", <<~JS, skip: true
  import "components/search_form"
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

  run "bin/importmap pin minisearch"
  run "bin/importmap pin tinykeys"

  insert_into_file "config/importmap.rb", after: /\A.*pin .+\n+/m do
    "\npin_all_from \"app/javascript/components\", under: \"components\"\npin_all_from \"app/javascript/helpers\", under: \"helpers\"\n"
  end

create_file "app/javascript/components/search_form.js", <<~'TEXT', force: true
import MiniSearch from "minisearch"
import { excerpt, highlight } from "helpers/search"

export default class SearchForm extends HTMLElement {
  #clickOutside = null
  #unsubscribe = null

  connectedCallback() {
    this.debounceTimeout = null
    this.selectedIndex = -1

    this.#input.addEventListener("focus", () => {
      this.setAttribute("data-focused", "")

      this.#initialize()
    })

    this.#input.addEventListener("blur", () => {
      this.removeAttribute("data-focused")
    })

    this.#setupClickOutside()

    if (!this.#submitButton) {
      this.#input.addEventListener("input", (event) => this.#debounce(event.target.value))
    } else {
      this.#submitButton.addEventListener("click", (event) => {
        event.preventDefault()

        this.#search(this.#input.value)
      })
    }

    this.#input.addEventListener("keydown", (event) => this.#navigate(event))

    if (this.hasAttribute("data-shortcut")) this.#setupShortcut()
  }

  disconnectedCallback() {
    if (this.debounceTimeout) clearTimeout(this.debounceTimeout)
    if (this.#unsubscribe) this.#unsubscribe()

    document.removeEventListener("mousedown", this.#clickOutside)
  }

  // private

  #setupClickOutside() {
    this.#clickOutside = (event) => {
      if (!this.contains(event.target)) {
        this.#close()
      }
    }

    document.addEventListener("mousedown", this.#clickOutside)
  }

  async #setupShortcut() {
    try {
      const imported = await import("tinykeys")
      const tinykeys = imported.default || imported.tinykeys || imported

      this.#unsubscribe = tinykeys(window, {
        [this.getAttribute("data-shortcut")]: (event) => {
          event.preventDefault()

          this.#input.focus()
        }
      })
    } catch {}
  }

  #navigate(event) {
    if (event.key === "Escape") {
      event.preventDefault()

      this.#close()

      return
    }

    if (!this.hasAttribute("data-open")) return

    const results = this.#resultsContainer.querySelectorAll("li a")
    if (results.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()

        this.selectedIndex = Math.min(this.selectedIndex + 1, results.length - 1)
        this.#updateSelection(results)

        break
      case "ArrowUp":
        event.preventDefault()

        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.#updateSelection(results)

        break
      case "Enter":
        event.preventDefault()

        if (this.selectedIndex >= 0) results[this.selectedIndex].click()

        break
    }
  }

  #debounce(query) {
    if (this.debounceTimeout) clearTimeout(this.debounceTimeout)

    this.debounceTimeout = setTimeout(() => this.#search(query), 150)
  }

  async #initialize() {
    if (this.index) return

    this.setAttribute("aria-busy", "true")

    try {
      const response = await fetch(this.#searchEndpoint)

      this.index = await response.json()
      this.miniSearch = new MiniSearch(this.#config)

      this.miniSearch.addAll(this.index)
    } catch (error) {
      console.error("Failed to load search index:", error)
    } finally {
      this.removeAttribute("aria-busy")
    }
  }

  #search(query) {
    if (query.trim().length < 2) {
      this.#close()

      return
    }

    const results = this.miniSearch.search(query)
    this.#render(results, query)
  }

  #close() {
    this.removeAttribute("data-open")
    this.removeAttribute("data-focused")
    this.removeAttribute("data-results")
    this.removeAttribute("data-empty")
    this.removeAttribute("data-results-count")

    this.#resultsContainer.innerHTML = ""
  }

  #render(results, query = "") {
    this.selectedIndex = -1

    if (results.length === 0) {
      this.#renderEmpty()

      return
    }

    const groupBy = this.getAttribute("data-group-by")
    const html = groupBy ? this.#renderGrouped(results, groupBy, query) : results.map(result => this.#renderItem(result, query)).join("")

    this.#resultsContainer.innerHTML = html

    this.#resultsContainer.querySelectorAll("li a").forEach(link => {
      link.addEventListener("mouseenter", () => {
        this.selectedIndex = -1

        this.#resultsContainer.querySelectorAll("li[data-selected]").forEach(item => item.removeAttribute("data-selected"))
      })
    })

    this.removeAttribute("data-empty")

    this.setAttribute("data-results-count", results.length)
    this.setAttribute("data-results", "")
    this.setAttribute("data-open", "")
  }

  #renderEmpty() {
    const emptyContainer = this.querySelector("[data-slot='empty']")

    if (emptyContainer) {
      emptyContainer.innerHTML = this.#emptyMessage
      emptyContainer.removeAttribute("hidden")
    }

    this.setAttribute("data-results-count", "0")
    this.setAttribute("data-empty", "")
    this.setAttribute("data-open", "")
  }

  #renderGrouped(results, groupBy, query) {
    const grouped = results.reduce((group, result) => {
      const key = result[groupBy] || "Other"

      if (!group[key]) {
        group[key] = []
      }

      group[key].push(result)

      return group
    }, {})

    return Object.entries(grouped).map(([group, items]) => `
      <li data-slot="group">
        <h6 data-group-label>${group}</h6>

        <ul data-slot="items">
          ${items.map(result => this.#renderItem(result, query)).join("")}
        </ul>
      </li>
    `).join("")
  }

  #renderItem(result, query) {
    return `
      <li data-slot="item">
        <a href="${result.href}" data-result-link>
          <h5 data-result-title>${highlight(result.title, query)}</h5>

          <p data-result-excerpt>${highlight(excerpt(result.body, query), query)}</p>
        </a>
      </li>
    `
  }

  #updateSelection(results) {
    results.forEach((result, index) => {
      const listItem = result.closest("li")

      if (index === this.selectedIndex) {
        listItem.setAttribute("data-selected", "")
        listItem.scrollIntoView({ block: "nearest" })
      } else {
        listItem.removeAttribute("data-selected")
      }
    })
  }

  get #config() {
    const defaults = {
      fields: ["title", "headings", "body"],
      idField: "slug",
      storeFields: ["title", "body", "href", "slug"],
      searchOptions: {
        prefix: true,
        boost: { title: 30, headings: 20 },
        combineWith: "and",
        fuzzy: true
      }
    }

    const customConfig = this.getAttribute("data-config")
    if (!customConfig) return defaults

    const parsed = JSON.parse(customConfig)

    return {
      ...defaults,
      ...parsed,
      fields: parsed.fields || defaults.fields,
      storeFields: [...new Set([...defaults.storeFields, ...(parsed.storeFields || [])])],
      searchOptions: {
        ...defaults.searchOptions,
        ...parsed.searchOptions,
        boost: {
          ...defaults.searchOptions.boost,
          ...parsed.searchOptions?.boost
        }
      }
    }
  }

  get #input() {
    return this.querySelector("input[type='search']")
  }

  get #submitButton() {
    return this.querySelector("button[type='submit']")
  }

  get #resultsContainer() {
    return this.querySelector("[data-slot='results']")
  }

  get #searchEndpoint() {
    return this.getAttribute("data-endpoint")
  }

  get #emptyMessage() {
    return this.getAttribute("data-empty") || "No results found"
  }
}

customElements.define("search-form", SearchForm)
TEXT

create_file "app/javascript/helpers/search.js", <<~'TEXT', force: true
export function excerpt(text, query, maxLength = 150) {
  const terms = query.trim().split(/\s+/).filter(Boolean)
  if (!terms.length) return truncate(text, maxLength)

  const pattern = terms.map(escapeRegex).join("|")
  const match = text.match(new RegExp(pattern, "i"))
  if (!match) return truncate(text, maxLength)

  const halfWindow = maxLength / 2
  const start = Math.max(0, match.index - halfWindow)
  const end = Math.min(text.length, start + maxLength)
  const snippet = text.slice(start, end)

  return `${start > 0 ? "…" : ""}${snippet}${end < text.length ? "…" : ""}`
}

export function highlight(text, query) {
  const terms = query.trim().split(/\s+/).filter(Boolean)
  if (!terms.length) return text

  const pattern = terms.map(escapeRegex).join("|")

  return text.replace(new RegExp(`(${pattern})`, "gi"), "<mark>$1</mark>")
}

function truncate(text, length) {
  return text.length > length ? `${text.slice(0, length)}…` : text
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]]\]/g, "\\$&")
}

TEXT
end
