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
  import "components/filter_items"
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

  create_file "app/javascript/application.js", <<~'TEXT', force: true
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "components"

TEXT

create_file "app/javascript/components/filter_items.js", <<~'TEXT', force: true
export default class FilterItems extends HTMLElement {
  #form = null
  #items = []
  #index = new Map()
  #unsubscribe = null

  static get observedAttributes() {
    return ["form", "mode"]
  }

  connectedCallback() {
    this.#initialize()
  }

  disconnectedCallback() {
    if (this.#unsubscribe) this.#unsubscribe()
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue === newValue) return
    if (name === "form") this.#initialize()
  }

  // private

  #initialize() {
    const formId = this.getAttribute("form")
    if (!formId) return

    this.#form = document.getElementById(formId)
    if (!this.#form) return

    this.#items = this.#allItems()
    this.#buildIndex()
    this.#observe()
    this.#filter()
  }

  #allItems() {
    return Array.from(this.children).filter((child) => {
      const hasFilterableAttributes = Array.from(child.attributes).some(
        (attribute) => {
          return (
            attribute.name.startsWith("data-") &&
            attribute.name !== "data-filter-exclude" &&
            attribute.name !== "data-empty-state"
          )
        }
      )

      return hasFilterableAttributes && !child.hasAttribute("data-empty-state")
    })
  }

  #buildIndex() {
    this.#index.clear()

    this.#attributeNames().forEach((name) => {
      const valueIndex = new Map()

      this.#items.forEach((item, index) => {
        const attributeValue = item.getAttribute(`data-${name}`) || ""
        const values = attributeValue
          .split(",")
          .map((value) => value.trim())
          .filter(Boolean)

        values.forEach((value) => {
          if (!valueIndex.has(value)) valueIndex.set(value, [])

          valueIndex.get(value).push(index)
        })
      })

      this.#index.set(name, valueIndex)
    })
  }

  #observe() {
    this.#unsubscribe = () => {}

    const handleChange = () => this.#filter()
    const inputs = this.#form.querySelectorAll("[name]")

    inputs.forEach((input) => {
      input.addEventListener("change", handleChange)
      input.addEventListener("input", handleChange)
    })

    this.#unsubscribe = () => {
      inputs.forEach((input) => {
        input.removeEventListener("change", handleChange)
        input.removeEventListener("input", handleChange)
      })
    }
  }
  #filter() {
    if (!this.#form) return

    const mode = this.getAttribute("mode") || "any"
    const activeInputs = this.#activeInputs
    const counts = {}

    this.#index.forEach((value, name) => {
      counts[name] = { total: 0, filtered: 0 }
    })

    this.#items.forEach((item) => {
      if (item.hasAttribute("data-filter-exclude")) {
        item.removeAttribute("hidden")

        return
      }

      const visible = this.#itemMatchesActiveInputs(item, activeInputs, mode)

      this.#index.forEach((value, name) => {
        const attributeValue = item.getAttribute(`data-${name}`) || ""

        if (attributeValue) counts[name].total++
        if (visible && attributeValue) counts[name].filtered++
      })

      if (visible) {
        item.removeAttribute("hidden")
      } else {
        item.setAttribute("hidden", "")
      }
    })

    this.#updateCounts(counts)
    this.#updateEmptyState()
    this.#dispatchFilterChangeEvent()
  }

  #attributeNames() {
    const names = new Set()

    this.#items.forEach((item) => {
      for (const attribute of item.attributes) {
        if (
          attribute.name.startsWith("data-") &&
          attribute.name !== "data-filter-exclude"
        ) {
          names.add(attribute.name.slice(5))
        }
      }
    })

    return names
  }

  #itemMatchesActiveInputs(item, activeInputs, mode) {
    if (activeInputs.length === 0) return true

    const matches = activeInputs.map((input) => {
      const itemValue = item.getAttribute(`data-${input.name}`) || ""
      const values = itemValue.split(",").map((value) => value.trim())

      return values.includes(input.value)
    })

    if (mode === "all") {
      return matches.every(Boolean)
    } else {
      return matches.some(Boolean)
    }
  }

  #updateCounts(counts) {
    Object.entries(counts).forEach(([name, count]) => {
      this.#form.setAttribute(`${name}-total-count`, count.total)
      this.#form.setAttribute(`${name}-filtered-count`, count.filtered)
    })
  }

  #updateEmptyState() {
    const activeInputs = this.#activeInputs
    const visibleItems = this.#items.filter(
      (item) =>
        !item.hasAttribute("data-filter-exclude") &&
        !item.hasAttribute("hidden")
    )

    const emptyState = this.querySelector("[data-empty-state]")
    if (emptyState) {
      if (activeInputs.length > 0 && visibleItems.length === 0) {
        emptyState.removeAttribute("hidden")
      } else {
        emptyState.setAttribute("hidden", "")
      }
    }
  }

  #dispatchFilterChangeEvent() {
    this.dispatchEvent(
      new CustomEvent("filterchange", {
        bubbles: true,
        detail: {
          form: this.#form,
          visibleCount: this.#items.filter(
            (item) => !item.hasAttribute("data-filter-exclude") && !item.hasAttribute("hidden")
          ).length,
          totalCount: this.#items.filter(
            (item) => !item.hasAttribute("data-filter-exclude")
          ).length
        }
      })
    )
  }


  get #activeInputs() {
    const inputs = this.#form.querySelectorAll("[name]")
    const active = []

    inputs.forEach((input) => {
      let value

      if (input.type === "checkbox" || input.type === "radio") {
        if (!input.checked) return

        value = input.value
      } else {
        value = input.value.trim()

        if (!value) return
      }

      active.push({ name: input.name, value })
    })

    return active
  }
}

customElements.define("filter-items", FilterItems)

TEXT
end
