gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  if File.exist?("app/assets/tailwind/application.css")
    insert_into_file "app/assets/tailwind/application.css", "\n@import ./components/content"
  end

  create_file "app/assets/tailwind//components/content.css", <<~'TEXT', force: true
@layer components {
  .content {
    & *:not(h1,h2,h3,h4,h5,h6)+*:not(pre,code,li,blockquote>p,svg,div[data-slot='code']),
    & blockquote+pre {
      @apply mt-5;
    }

    & h2 {
      @apply font-bold text-2xl text-gray-800;
    }

    & h3 {
      @apply font-semibold text-xl text-gray-800;
    }

    & h4 {
      @apply font-semibold text-lg text-gray-800;
    }

    & > p,
    & li {
      @apply text-lg;
    }

    & > p {
      @apply text-gray-950;
    }

    & ul,
    & ol {
      @apply mt-2 list-outside;
    }

    & ul {
      @apply list-disc ml-4.5;
    }

    & ol {
      @apply list-decimal ml-5;
    }

    & pre {
      @apply w-full mt-1.25 px-1.5 py-2 sm:px-3 sm:py-4 border border-gray-100 rounded-md overflow-auto;
    }

    & code {
      @apply p-0.5 text-[0.8em] font-medium bg-gray-100 rounded-sm;
    }

    & pre > code {
      @apply text-base font-normal bg-transparent;
    }

    & blockquote:not(:has(svg)) {
      @apply pl-3 italic text-gray-600 border-l-2 border-gray-200;
    }

    & strong {
      @apply font-semibold;
    }

    & table {
      @apply w-full text-left text-sm;
    }

    & thead {
      @apply border-b border-gray-200;
    }

    & th {
      @apply px-2 py-1.5 font-semibold text-gray-800;
    }

    & tbody tr {
      @apply border-b border-gray-100;
    }

    & tbody tr:last-child {
      @apply border-0;
    }

    & td {
      @apply px-2 py-1.5 align-top text-sm text-gray-800 sm:text-base;
    }

    & img {
      @apply w-full max-w-3xl p-2 border border-gray-200 rounded-lg;
    }

    & hr {
      @apply border-gray-200;
    }

    @apply marker:text-gray-500;
  }
}

TEXT

create_file "app/assets/tailwind/components/content.css", <<~'TEXT', force: true
@layer components {
  .content {
    & *:not(h1,h2,h3,h4,h5,h6)+*:not(pre,code,li,blockquote>p,svg,div[data-slot='code']),
    & blockquote+pre {
      @apply mt-5;
    }

    & h2 {
      @apply font-bold text-2xl text-gray-800;
    }

    & h3 {
      @apply font-semibold text-xl text-gray-800;
    }

    & h4 {
      @apply font-semibold text-lg text-gray-800;
    }

    & > p,
    & li {
      @apply text-lg;
    }

    & > p {
      @apply text-gray-950;
    }

    & ul,
    & ol {
      @apply mt-2 list-outside;
    }

    & ul {
      @apply list-disc ml-4.5;
    }

    & ol {
      @apply list-decimal ml-5;
    }

    & pre {
      @apply w-full mt-1.25 px-1.5 py-2 sm:px-3 sm:py-4 border border-gray-100 rounded-md overflow-auto;
    }

    & code {
      @apply p-0.5 text-[0.8em] font-medium bg-gray-100 rounded-sm;
    }

    & pre > code {
      @apply text-base font-normal bg-transparent;
    }

    & blockquote:not(:has(svg)) {
      @apply pl-3 italic text-gray-600 border-l-2 border-gray-200;
    }

    & strong {
      @apply font-semibold;
    }

    & table {
      @apply w-full text-left text-sm;
    }

    & thead {
      @apply border-b border-gray-200;
    }

    & th {
      @apply px-2 py-1.5 font-semibold text-gray-800;
    }

    & tbody tr {
      @apply border-b border-gray-100;
    }

    & tbody tr:last-child {
      @apply border-0;
    }

    & td {
      @apply px-2 py-1.5 align-top text-sm text-gray-800 sm:text-base;
    }

    & img {
      @apply w-full max-w-3xl p-2 border border-gray-200 rounded-lg;
    }

    & hr {
      @apply border-gray-200;
    }

    @apply marker:text-gray-500;
  }
}

TEXT
end
