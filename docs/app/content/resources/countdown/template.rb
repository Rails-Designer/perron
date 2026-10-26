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
import "./count_down"
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

file "app/javascript/components/count-down.js" do
<<~"_"
// Usage

// Provide a `to-time` attribute with an ISO 8601 datetime string:
// ```html
// <count-down to-time="2026-12-31T23:59:59Z"></count-down>
// ```
//
class CountDown extends HTMLElement {
  #intervalId = null;

  static get observedAttributes() {
    return ["to-time", "complete-text"];
  }

  connectedCallback() {
    this.#update();
  }

  disconnectedCallback() {
    this.#stop();
  }

  attributeChangedCallback() {
    this.#update();
  }

  // private

  #update() {
    this.#stop();

    if (this.toTime) {
      this.#tick();

      this.#intervalId = setInterval(() => this.#tick(), 1000);
    }
  }

  #tick() {
    const now = new Date();
    const target = new Date(this.toTime);
    const difference = target - now;

    if (difference <= 0) {
      this.textContent = this.completeText;
      this.#stop();

      return;
    }

    const days = Math.floor(difference / (1000 * 60 * 60 * 24));
    const hours = Math.floor((difference %% (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((difference %% (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((difference %% (1000 * 60)) / 1000);

    this.textContent = `${days}d ${hours}h ${minutes}m ${seconds}s`;
  }

  #stop() {
    if (!this.#intervalId) return

    clearInterval(this.#intervalId);

    this.#intervalId = null;
  }

  get toTime() {
    return this.getAttribute("to-time");
  }

  set toTime(value) {
    if (value === null) {
      this.removeAttribute("to-time");
    } else {
      this.setAttribute("to-time", value);
    }
  }

  get completeText() {
    return this.getAttribute("complete-text") || "0d 0h 0m 0s";
  }

  set completeText(value) {
    if (value === null) {
      this.removeAttribute("complete-text");
    } else {
      this.setAttribute("complete-text", value);
    }
  }
}

customElements.define("count-down", CountDown);

_
end
end
