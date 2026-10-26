// minisearch@7.2.0 downloaded from https://ga.jspm.io/npm:minisearch@7.2.0/dist/es/index.js

const t="ENTRIES";const e="KEYS";const s="VALUES";const n="";class TreeIterator{constructor(t,e){const s=t._tree;const n=Array.from(s.keys());this.set=t;this._type=e;this._path=n.length>0?[{node:s,keys:n}]:[]}next(){const t=this.dive();this.backtrack();return t}dive(){if(this._path.length===0)return{done:true,value:void 0};const{node:t,keys:e}=i(this._path);if(i(e)===n)return{done:false,value:this.result()};const s=t.get(i(e));this._path.push({node:s,keys:Array.from(s.keys())});return this.dive()}backtrack(){if(this._path.length===0)return;const t=i(this._path).keys;t.pop();if(!(t.length>0)){this._path.pop();this.backtrack()}}key(){return this.set._prefix+this._path.map((({keys:t})=>i(t))).filter((t=>t!==n)).join("")}value(){return i(this._path).node.get(n)}result(){switch(this._type){case s:return this.value();case e:return this.key();default:return[this.key(),this.value()]}}[Symbol.iterator](){return this}}const i=t=>t[t.length-1];const o=(t,e,s)=>{const n=new Map;if(e===void 0)return n;const i=e.length+1;const o=i+s;const c=new Uint8Array(o*i).fill(s+1);for(let t=0;t<i;++t)c[t]=t;for(let t=1;t<o;++t)c[t*i]=t;r(t,e,s,n,c,1,i,"");return n};const r=(t,e,s,i,o,c,h,u)=>{const d=c*h;t:for(const a of t.keys())if(a===n){const e=o[d-1];e<=s&&i.set(u,[t.get(a),e])}else{let n=c;for(let t=0;t<a.length;++t,++n){const i=a[t];const r=h*n;const c=r-h;let u=o[r];const d=Math.max(0,n-s-1);const l=Math.min(h-1,n+s);for(let t=d;t<l;++t){const s=i!==e[t];const n=o[c+t]+ +s;const h=o[c+t+1]+1;const d=o[r+t]+1;const a=o[r+t+1]=Math.min(n,h,d);a<u&&(u=a)}if(u>s)continue t}r(t.get(a),e,s,i,o,n,h,u+a)}};
/**
 * A class implementing the same interface as a standard JavaScript
 * [`Map`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)
 * with string keys, but adding support for efficiently searching entries with
 * prefix or fuzzy search. This class is used internally by {@link MiniSearch}
 * as the inverted index data structure. The implementation is a radix tree
 * (compressed prefix tree).
 *
 * Since this class can be of general utility beyond _MiniSearch_, it is
 * exported by the `minisearch` package and can be imported (or required) as
 * `minisearch/SearchableMap`.
 *
 * @typeParam T  The type of the values stored in the map.
 */class SearchableMap{constructor(t=new Map,e=""){this._size=void 0;this._tree=t;this._prefix=e}
/**
     * Creates and returns a mutable view of this {@link SearchableMap},
     * containing only entries that share the given prefix.
     *
     * ### Usage:
     *
     * ```javascript
     * let map = new SearchableMap()
     * map.set("unicorn", 1)
     * map.set("universe", 2)
     * map.set("university", 3)
     * map.set("unique", 4)
     * map.set("hello", 5)
     *
     * let uni = map.atPrefix("uni")
     * uni.get("unique") // => 4
     * uni.get("unicorn") // => 1
     * uni.get("hello") // => undefined
     *
     * let univer = map.atPrefix("univer")
     * univer.get("unique") // => undefined
     * univer.get("universe") // => 2
     * univer.get("university") // => 3
     * ```
     *
     * @param prefix  The prefix
     * @return A {@link SearchableMap} representing a mutable view of the original
     * Map at the given prefix
     */atPrefix(t){if(!t.startsWith(this._prefix))throw new Error("Mismatched prefix");const[e,s]=c(this._tree,t.slice(this._prefix.length));if(e===void 0){const[e,i]=f(s);for(const s of e.keys())if(s!==n&&s.startsWith(i)){const n=new Map;n.set(s.slice(i.length),e.get(s));return new SearchableMap(n,t)}}return new SearchableMap(e,t)}clear(){this._size=void 0;this._tree.clear()}
/**
     * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map/delete
     * @param key  Key to delete
     */delete(t){this._size=void 0;return d(this._tree,t)}entries(){return new TreeIterator(this,t)}
/**
     * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map/forEach
     * @param fn  Iteration function
     */forEach(t){for(const[e,s]of this)t(e,s,this)}
/**
     * Returns a Map of all the entries that have a key within the given edit
     * distance from the search key. The keys of the returned Map are the matching
     * keys, while the values are two-element arrays where the first element is
     * the value associated to the key, and the second is the edit distance of the
     * key to the search key.
     *
     * ### Usage:
     *
     * ```javascript
     * let map = new SearchableMap()
     * map.set('hello', 'world')
     * map.set('hell', 'yeah')
     * map.set('ciao', 'mondo')
     *
     * // Get all entries that match the key 'hallo' with a maximum edit distance of 2
     * map.fuzzyGet('hallo', 2)
     * // => Map(2) { 'hello' => ['world', 1], 'hell' => ['yeah', 2] }
     *
     * // In the example, the "hello" key has value "world" and edit distance of 1
     * // (change "e" to "a"), the key "hell" has value "yeah" and edit distance of 2
     * // (change "e" to "a", delete "o")
     * ```
     *
     * @param key  The search key
     * @param maxEditDistance  The maximum edit distance (Levenshtein)
     * @return A Map of the matching keys to their value and edit distance
     */fuzzyGet(t,e){return o(this._tree,t,e)}
/**
     * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map/get
     * @param key  Key to get
     * @return Value associated to the key, or `undefined` if the key is not
     * found.
     */get(t){const e=h(this._tree,t);return e!==void 0?e.get(n):void 0}
/**
     * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map/has
     * @param key  Key
     * @return True if the key is in the map, false otherwise
     */has(t){const e=h(this._tree,t);return e!==void 0&&e.has(n)}keys(){return new TreeIterator(this,e)}
/**
     * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map/set
     * @param key  Key to set
     * @param value  Value to associate to the key
     * @return The {@link SearchableMap} itself, to allow chaining
     */set(t,e){if(typeof t!=="string")throw new Error("key must be a string");this._size=void 0;const s=u(this._tree,t);s.set(n,e);return this}get size(){if(this._size)return this._size;this._size=0;const t=this.entries();while(!t.next().done)this._size+=1;return this._size}
/**
     * Updates the value at the given key using the provided function. The function
     * is called with the current value at the key, and its return value is used as
     * the new value to be set.
     *
     * ### Example:
     *
     * ```javascript
     * // Increment the current value by one
     * searchableMap.update('somekey', (currentValue) => currentValue == null ? 0 : currentValue + 1)
     * ```
     *
     * If the value at the given key is or will be an object, it might not require
     * re-assignment. In that case it is better to use `fetch()`, because it is
     * faster.
     *
     * @param key  The key to update
     * @param fn  The function used to compute the new value from the current one
     * @return The {@link SearchableMap} itself, to allow chaining
     */update(t,e){if(typeof t!=="string")throw new Error("key must be a string");this._size=void 0;const s=u(this._tree,t);s.set(n,e(s.get(n)));return this}
/**
     * Fetches the value of the given key. If the value does not exist, calls the
     * given function to create a new value, which is inserted at the given key
     * and subsequently returned.
     *
     * ### Example:
     *
     * ```javascript
     * const map = searchableMap.fetch('somekey', () => new Map())
     * map.set('foo', 'bar')
     * ```
     *
     * @param key  The key to update
     * @param initial  A function that creates a new value if the key does not exist
     * @return The existing or new value at the given key
     */fetch(t,e){if(typeof t!=="string")throw new Error("key must be a string");this._size=void 0;const s=u(this._tree,t);let i=s.get(n);i===void 0&&s.set(n,i=e());return i}values(){return new TreeIterator(this,s)}[Symbol.iterator](){return this.entries()}
/**
     * Creates a {@link SearchableMap} from an `Iterable` of entries
     *
     * @param entries  Entries to be inserted in the {@link SearchableMap}
     * @return A new {@link SearchableMap} with the given entries
     */static from(t){const e=new SearchableMap;for(const[s,n]of t)e.set(s,n);return e}
/**
     * Creates a {@link SearchableMap} from the iterable properties of a JavaScript object
     *
     * @param object  Object of entries for the {@link SearchableMap}
     * @return A new {@link SearchableMap} with the given entries
     */static fromObject(t){return SearchableMap.from(Object.entries(t))}}const c=(t,e,s=[])=>{if(e.length===0||t==null)return[t,s];for(const i of t.keys())if(i!==n&&e.startsWith(i)){s.push([t,i]);return c(t.get(i),e.slice(i.length),s)}s.push([t,e]);return c(void 0,"",s)};const h=(t,e)=>{if(e.length===0||t==null)return t;for(const s of t.keys())if(s!==n&&e.startsWith(s))return h(t.get(s),e.slice(s.length))};const u=(t,e)=>{const s=e.length;t:for(let i=0;t&&i<s;){for(const o of t.keys())if(o!==n&&e[i]===o[0]){const n=Math.min(s-i,o.length);let r=1;while(r<n&&e[i+r]===o[r])++r;const c=t.get(o);if(r===o.length)t=c;else{const s=new Map;s.set(o.slice(r),c);t.set(e.slice(i,i+r),s);t.delete(o);t=s}i+=r;continue t}const o=new Map;t.set(e.slice(i),o);return o}return t};const d=(t,e)=>{const[s,i]=c(t,e);if(s!==void 0){s.delete(n);if(s.size===0)a(i);else if(s.size===1){const[t,e]=s.entries().next().value;l(i,t,e)}}};const a=t=>{if(t.length===0)return;const[e,s]=f(t);e.delete(s);if(e.size===0)a(t.slice(0,-1));else if(e.size===1){const[s,i]=e.entries().next().value;s!==n&&l(t.slice(0,-1),s,i)}};const l=(t,e,s)=>{if(t.length===0)return;const[n,i]=f(t);n.set(i+e,s);n.delete(i)};const f=t=>t[t.length-1];const m="or";const _="and";const g="and_not";
/**
 * {@link MiniSearch} is the main entrypoint class, implementing a full-text
 * search engine in memory.
 *
 * @typeParam T  The type of the documents being indexed.
 *
 * ### Basic example:
 *
 * ```javascript
 * const documents = [
 *   {
 *     id: 1,
 *     title: 'Moby Dick',
 *     text: 'Call me Ishmael. Some years ago...',
 *     category: 'fiction'
 *   },
 *   {
 *     id: 2,
 *     title: 'Zen and the Art of Motorcycle Maintenance',
 *     text: 'I can see by my watch...',
 *     category: 'fiction'
 *   },
 *   {
 *     id: 3,
 *     title: 'Neuromancer',
 *     text: 'The sky above the port was...',
 *     category: 'fiction'
 *   },
 *   {
 *     id: 4,
 *     title: 'Zen and the Art of Archery',
 *     text: 'At first sight it must seem...',
 *     category: 'non-fiction'
 *   },
 *   // ...and more
 * ]
 *
 * // Create a search engine that indexes the 'title' and 'text' fields for
 * // full-text search. Search results will include 'title' and 'category' (plus the
 * // id field, that is always stored and returned)
 * const miniSearch = new MiniSearch({
 *   fields: ['title', 'text'],
 *   storeFields: ['title', 'category']
 * })
 *
 * // Add documents to the index
 * miniSearch.addAll(documents)
 *
 * // Search for documents:
 * let results = miniSearch.search('zen art motorcycle')
 * // => [
 * //   { id: 2, title: 'Zen and the Art of Motorcycle Maintenance', category: 'fiction', score: 2.77258 },
 * //   { id: 4, title: 'Zen and the Art of Archery', category: 'non-fiction', score: 1.38629 }
 * // ]
 * ```
 */class MiniSearch{
/**
     * @param options  Configuration options
     *
     * ### Examples:
     *
     * ```javascript
     * // Create a search engine that indexes the 'title' and 'text' fields of your
     * // documents:
     * const miniSearch = new MiniSearch({ fields: ['title', 'text'] })
     * ```
     *
     * ### ID Field:
     *
     * ```javascript
     * // Your documents are assumed to include a unique 'id' field, but if you want
     * // to use a different field for document identification, you can set the
     * // 'idField' option:
     * const miniSearch = new MiniSearch({ idField: 'key', fields: ['title', 'text'] })
     * ```
     *
     * ### Options and defaults:
     *
     * ```javascript
     * // The full set of options (here with their default value) is:
     * const miniSearch = new MiniSearch({
     *   // idField: field that uniquely identifies a document
     *   idField: 'id',
     *
     *   // extractField: function used to get the value of a field in a document.
     *   // By default, it assumes the document is a flat object with field names as
     *   // property keys and field values as string property values, but custom logic
     *   // can be implemented by setting this option to a custom extractor function.
     *   extractField: (document, fieldName) => document[fieldName],
     *
     *   // tokenize: function used to split fields into individual terms. By
     *   // default, it is also used to tokenize search queries, unless a specific
     *   // `tokenize` search option is supplied. When tokenizing an indexed field,
     *   // the field name is passed as the second argument.
     *   tokenize: (string, _fieldName) => string.split(SPACE_OR_PUNCTUATION),
     *
     *   // processTerm: function used to process each tokenized term before
     *   // indexing. It can be used for stemming and normalization. Return a falsy
     *   // value in order to discard a term. By default, it is also used to process
     *   // search queries, unless a specific `processTerm` option is supplied as a
     *   // search option. When processing a term from a indexed field, the field
     *   // name is passed as the second argument.
     *   processTerm: (term, _fieldName) => term.toLowerCase(),
     *
     *   // searchOptions: default search options, see the `search` method for
     *   // details
     *   searchOptions: undefined,
     *
     *   // fields: document fields to be indexed. Mandatory, but not set by default
     *   fields: undefined
     *
     *   // storeFields: document fields to be stored and returned as part of the
     *   // search results.
     *   storeFields: []
     * })
     * ```
     */
constructor(t){if((t===null||t===void 0?void 0:t.fields)==null)throw new Error('MiniSearch: option "fields" must be provided');const e=t.autoVacuum==null||t.autoVacuum===true?F:t.autoVacuum;this._options={...b,...t,autoVacuum:e,searchOptions:{...x,...t.searchOptions||{}},autoSuggestOptions:{...z,...t.autoSuggestOptions||{}}};this._index=new SearchableMap;this._documentCount=0;this._documentIds=new Map;this._idToShortId=new Map;this._fieldIds={};this._fieldLength=new Map;this._avgFieldLength=[];this._nextId=0;this._storedFields=new Map;this._dirtCount=0;this._currentVacuum=null;this._enqueuedVacuum=null;this._enqueuedVacuumConditions=M;this.addFields(this._options.fields)}
/**
     * Adds a document to the index
     *
     * @param document  The document to be indexed
     */add(t){const{extractField:e,stringifyField:s,tokenize:n,processTerm:i,fields:o,idField:r}=this._options;const c=e(t,r);if(c==null)throw new Error(`MiniSearch: document does not have ID field "${r}"`);if(this._idToShortId.has(c))throw new Error(`MiniSearch: duplicate ID ${c}`);const h=this.addDocumentId(c);this.saveStoredFields(h,t);for(const r of o){const o=e(t,r);if(o==null)continue;const c=n(s(o,r),r);const u=this._fieldIds[r];const d=new Set(c).size;this.addFieldLength(h,u,this._documentCount-1,d);for(const t of c){const e=i(t,r);if(Array.isArray(e))for(const t of e)this.addTerm(u,h,t);else e&&this.addTerm(u,h,e)}}}
/**
     * Adds all the given documents to the index
     *
     * @param documents  An array of documents to be indexed
     */addAll(t){for(const e of t)this.add(e)}
/**
     * Adds all the given documents to the index asynchronously.
     *
     * Returns a promise that resolves (to `undefined`) when the indexing is done.
     * This method is useful when index many documents, to avoid blocking the main
     * thread. The indexing is performed asynchronously and in chunks.
     *
     * @param documents  An array of documents to be indexed
     * @param options  Configuration options
     * @return A promise resolving to `undefined` when the indexing is done
     */addAllAsync(t,e={}){const{chunkSize:s=10}=e;const n={chunk:[],promise:Promise.resolve()};const{chunk:i,promise:o}=t.reduce((({chunk:t,promise:e},n,i)=>{t.push(n);return(i+1)%s===0?{chunk:[],promise:e.then((()=>new Promise((t=>setTimeout(t,0))))).then((()=>this.addAll(t)))}:{chunk:t,promise:e}}),n);return o.then((()=>this.addAll(i)))}
/**
     * Removes the given document from the index.
     *
     * The document to remove must NOT have changed between indexing and removal,
     * otherwise the index will be corrupted.
     *
     * This method requires passing the full document to be removed (not just the
     * ID), and immediately removes the document from the inverted index, allowing
     * memory to be released. A convenient alternative is {@link
     * MiniSearch#discard}, which needs only the document ID, and has the same
     * visible effect, but delays cleaning up the index until the next vacuuming.
     *
     * @param document  The document to be removed
     */remove(t){const{tokenize:e,processTerm:s,extractField:n,stringifyField:i,fields:o,idField:r}=this._options;const c=n(t,r);if(c==null)throw new Error(`MiniSearch: document does not have ID field "${r}"`);const h=this._idToShortId.get(c);if(h==null)throw new Error(`MiniSearch: cannot remove document with ID ${c}: it is not in the index`);for(const r of o){const o=n(t,r);if(o==null)continue;const c=e(i(o,r),r);const u=this._fieldIds[r];const d=new Set(c).size;this.removeFieldLength(h,u,this._documentCount,d);for(const t of c){const e=s(t,r);if(Array.isArray(e))for(const t of e)this.removeTerm(u,h,t);else e&&this.removeTerm(u,h,e)}}this._storedFields.delete(h);this._documentIds.delete(h);this._idToShortId.delete(c);this._fieldLength.delete(h);this._documentCount-=1}
/**
     * Removes all the given documents from the index. If called with no arguments,
     * it removes _all_ documents from the index.
     *
     * @param documents  The documents to be removed. If this argument is omitted,
     * all documents are removed. Note that, for removing all documents, it is
     * more efficient to call this method with no arguments than to pass all
     * documents.
     */removeAll(t){if(t)for(const e of t)this.remove(e);else{if(arguments.length>0)throw new Error("Expected documents to be present. Omit the argument to remove all documents.");this._index=new SearchableMap;this._documentCount=0;this._documentIds=new Map;this._idToShortId=new Map;this._fieldLength=new Map;this._avgFieldLength=[];this._storedFields=new Map;this._nextId=0}}
/**
     * Discards the document with the given ID, so it won't appear in search results
     *
     * It has the same visible effect of {@link MiniSearch.remove} (both cause the
     * document to stop appearing in searches), but a different effect on the
     * internal data structures:
     *
     *   - {@link MiniSearch#remove} requires passing the full document to be
     *   removed as argument, and removes it from the inverted index immediately.
     *
     *   - {@link MiniSearch#discard} instead only needs the document ID, and
     *   works by marking the current version of the document as discarded, so it
     *   is immediately ignored by searches. This is faster and more convenient
     *   than {@link MiniSearch#remove}, but the index is not immediately
     *   modified. To take care of that, vacuuming is performed after a certain
     *   number of documents are discarded, cleaning up the index and allowing
     *   memory to be released.
     *
     * After discarding a document, it is possible to re-add a new version, and
     * only the new version will appear in searches. In other words, discarding
     * and re-adding a document works exactly like removing and re-adding it. The
     * {@link MiniSearch.replace} method can also be used to replace a document
     * with a new version.
     *
     * #### Details about vacuuming
     *
     * Repetite calls to this method would leave obsolete document references in
     * the index, invisible to searches. Two mechanisms take care of cleaning up:
     * clean up during search, and vacuuming.
     *
     *   - Upon search, whenever a discarded ID is found (and ignored for the
     *   results), references to the discarded document are removed from the
     *   inverted index entries for the search terms. This ensures that subsequent
     *   searches for the same terms do not need to skip these obsolete references
     *   again.
     *
     *   - In addition, vacuuming is performed automatically by default (see the
     *   `autoVacuum` field in {@link Options}) after a certain number of
     *   documents are discarded. Vacuuming traverses all terms in the index,
     *   cleaning up all references to discarded documents. Vacuuming can also be
     *   triggered manually by calling {@link MiniSearch#vacuum}.
     *
     * @param id  The ID of the document to be discarded
     */discard(t){const e=this._idToShortId.get(t);if(e==null)throw new Error(`MiniSearch: cannot discard document with ID ${t}: it is not in the index`);this._idToShortId.delete(t);this._documentIds.delete(e);this._storedFields.delete(e);(this._fieldLength.get(e)||[]).forEach(((t,s)=>{this.removeFieldLength(e,s,this._documentCount,t)}));this._fieldLength.delete(e);this._documentCount-=1;this._dirtCount+=1;this.maybeAutoVacuum()}maybeAutoVacuum(){if(this._options.autoVacuum===false)return;const{minDirtFactor:t,minDirtCount:e,batchSize:s,batchWait:n}=this._options.autoVacuum;this.conditionalVacuum({batchSize:s,batchWait:n},{minDirtCount:e,minDirtFactor:t})}discardAll(t){const e=this._options.autoVacuum;try{this._options.autoVacuum=false;for(const e of t)this.discard(e)}finally{this._options.autoVacuum=e}this.maybeAutoVacuum()}
/**
     * It replaces an existing document with the given updated version
     *
     * It works by discarding the current version and adding the updated one, so
     * it is functionally equivalent to calling {@link MiniSearch#discard}
     * followed by {@link MiniSearch#add}. The ID of the updated document should
     * be the same as the original one.
     *
     * Since it uses {@link MiniSearch#discard} internally, this method relies on
     * vacuuming to clean up obsolete document references from the index, allowing
     * memory to be released (see {@link MiniSearch#discard}).
     *
     * @param updatedDocument  The updated document to replace the old version
     * with
     */replace(t){const{idField:e,extractField:s}=this._options;const n=s(t,e);this.discard(n);this.add(t)}
/**
     * Triggers a manual vacuuming, cleaning up references to discarded documents
     * from the inverted index
     *
     * Vacuuming is only useful for applications that use the {@link
     * MiniSearch#discard} or {@link MiniSearch#replace} methods.
     *
     * By default, vacuuming is performed automatically when needed (controlled by
     * the `autoVacuum` field in {@link Options}), so there is usually no need to
     * call this method, unless one wants to make sure to perform vacuuming at a
     * specific moment.
     *
     * Vacuuming traverses all terms in the inverted index in batches, and cleans
     * up references to discarded documents from the posting list, allowing memory
     * to be released.
     *
     * The method takes an optional object as argument with the following keys:
     *
     *   - `batchSize`: the size of each batch (1000 by default)
     *
     *   - `batchWait`: the number of milliseconds to wait between batches (10 by
     *   default)
     *
     * On large indexes, vacuuming could have a non-negligible cost: batching
     * avoids blocking the thread for long, diluting this cost so that it is not
     * negatively affecting the application. Nonetheless, this method should only
     * be called when necessary, and relying on automatic vacuuming is usually
     * better.
     *
     * It returns a promise that resolves (to undefined) when the clean up is
     * completed. If vacuuming is already ongoing at the time this method is
     * called, a new one is enqueued immediately after the ongoing one, and a
     * corresponding promise is returned. However, no more than one vacuuming is
     * enqueued on top of the ongoing one, even if this method is called more
     * times (enqueuing multiple ones would be useless).
     *
     * @param options  Configuration options for the batch size and delay. See
     * {@link VacuumOptions}.
     */vacuum(t={}){return this.conditionalVacuum(t)}conditionalVacuum(t,e){if(this._currentVacuum){this._enqueuedVacuumConditions=this._enqueuedVacuumConditions&&e;if(this._enqueuedVacuum!=null)return this._enqueuedVacuum;this._enqueuedVacuum=this._currentVacuum.then((()=>{const e=this._enqueuedVacuumConditions;this._enqueuedVacuumConditions=M;return this.performVacuuming(t,e)}));return this._enqueuedVacuum}if(this.vacuumConditionsMet(e)===false)return Promise.resolve();this._currentVacuum=this.performVacuuming(t);return this._currentVacuum}async performVacuuming(t,e){const s=this._dirtCount;if(this.vacuumConditionsMet(e)){const e=t.batchSize||I.batchSize;const n=t.batchWait||I.batchWait;let i=1;for(const[t,s]of this._index){for(const[t,e]of s)for(const[n]of e)this._documentIds.has(n)||(e.size<=1?s.delete(t):e.delete(n));this._index.get(t).size===0&&this._index.delete(t);i%e===0&&await new Promise((t=>setTimeout(t,n)));i+=1}this._dirtCount-=s}await null;this._currentVacuum=this._enqueuedVacuum;this._enqueuedVacuum=null}vacuumConditionsMet(t){if(t==null)return true;let{minDirtCount:e,minDirtFactor:s}=t;e=e||F.minDirtCount;s=s||F.minDirtFactor;return this.dirtCount>=e&&this.dirtFactor>=s}get isVacuuming(){return this._currentVacuum!=null}get dirtCount(){return this._dirtCount}get dirtFactor(){return this._dirtCount/(1+this._documentCount+this._dirtCount)}
/**
     * Returns `true` if a document with the given ID is present in the index and
     * available for search, `false` otherwise
     *
     * @param id  The document ID
     */has(t){return this._idToShortId.has(t)}
/**
     * Returns the stored fields (as configured in the `storeFields` constructor
     * option) for the given document ID. Returns `undefined` if the document is
     * not present in the index.
     *
     * @param id  The document ID
     */getStoredFields(t){const e=this._idToShortId.get(t);if(e!=null)return this._storedFields.get(e)}
/**
     * Search for documents matching the given search query.
     *
     * The result is a list of scored document IDs matching the query, sorted by
     * descending score, and each including data about which terms were matched and
     * in which fields.
     *
     * ### Basic usage:
     *
     * ```javascript
     * // Search for "zen art motorcycle" with default options: terms have to match
     * // exactly, and individual terms are joined with OR
     * miniSearch.search('zen art motorcycle')
     * // => [ { id: 2, score: 2.77258, match: { ... } }, { id: 4, score: 1.38629, match: { ... } } ]
     * ```
     *
     * ### Restrict search to specific fields:
     *
     * ```javascript
     * // Search only in the 'title' field
     * miniSearch.search('zen', { fields: ['title'] })
     * ```
     *
     * ### Field boosting:
     *
     * ```javascript
     * // Boost a field
     * miniSearch.search('zen', { boost: { title: 2 } })
     * ```
     *
     * ### Prefix search:
     *
     * ```javascript
     * // Search for "moto" with prefix search (it will match documents
     * // containing terms that start with "moto" or "neuro")
     * miniSearch.search('moto neuro', { prefix: true })
     * ```
     *
     * ### Fuzzy search:
     *
     * ```javascript
     * // Search for "ismael" with fuzzy search (it will match documents containing
     * // terms similar to "ismael", with a maximum edit distance of 0.2 term.length
     * // (rounded to nearest integer)
     * miniSearch.search('ismael', { fuzzy: 0.2 })
     * ```
     *
     * ### Combining strategies:
     *
     * ```javascript
     * // Mix of exact match, prefix search, and fuzzy search
     * miniSearch.search('ismael mob', {
     *  prefix: true,
     *  fuzzy: 0.2
     * })
     * ```
     *
     * ### Advanced prefix and fuzzy search:
     *
     * ```javascript
     * // Perform fuzzy and prefix search depending on the search term. Here
     * // performing prefix and fuzzy search only on terms longer than 3 characters
     * miniSearch.search('ismael mob', {
     *  prefix: term => term.length > 3
     *  fuzzy: term => term.length > 3 ? 0.2 : null
     * })
     * ```
     *
     * ### Combine with AND:
     *
     * ```javascript
     * // Combine search terms with AND (to match only documents that contain both
     * // "motorcycle" and "art")
     * miniSearch.search('motorcycle art', { combineWith: 'AND' })
     * ```
     *
     * ### Combine with AND_NOT:
     *
     * There is also an AND_NOT combinator, that finds documents that match the
     * first term, but do not match any of the other terms. This combinator is
     * rarely useful with simple queries, and is meant to be used with advanced
     * query combinations (see later for more details).
     *
     * ### Filtering results:
     *
     * ```javascript
     * // Filter only results in the 'fiction' category (assuming that 'category'
     * // is a stored field)
     * miniSearch.search('motorcycle art', {
     *   filter: (result) => result.category === 'fiction'
     * })
     * ```
     *
     * ### Wildcard query
     *
     * Searching for an empty string (assuming the default tokenizer) returns no
     * results. Sometimes though, one needs to match all documents, like in a
     * "wildcard" search. This is possible by passing the special value
     * {@link MiniSearch.wildcard} as the query:
     *
     * ```javascript
     * // Return search results for all documents
     * miniSearch.search(MiniSearch.wildcard)
     * ```
     *
     * Note that search options such as `filter` and `boostDocument` are still
     * applied, influencing which results are returned, and their order:
     *
     * ```javascript
     * // Return search results for all documents in the 'fiction' category
     * miniSearch.search(MiniSearch.wildcard, {
     *   filter: (result) => result.category === 'fiction'
     * })
     * ```
     *
     * ### Advanced combination of queries:
     *
     * It is possible to combine different subqueries with OR, AND, and AND_NOT,
     * and even with different search options, by passing a query expression
     * tree object as the first argument, instead of a string.
     *
     * ```javascript
     * // Search for documents that contain "zen" and ("motorcycle" or "archery")
     * miniSearch.search({
     *   combineWith: 'AND',
     *   queries: [
     *     'zen',
     *     {
     *       combineWith: 'OR',
     *       queries: ['motorcycle', 'archery']
     *     }
     *   ]
     * })
     *
     * // Search for documents that contain ("apple" or "pear") but not "juice" and
     * // not "tree"
     * miniSearch.search({
     *   combineWith: 'AND_NOT',
     *   queries: [
     *     {
     *       combineWith: 'OR',
     *       queries: ['apple', 'pear']
     *     },
     *     'juice',
     *     'tree'
     *   ]
     * })
     * ```
     *
     * Each node in the expression tree can be either a string, or an object that
     * supports all {@link SearchOptions} fields, plus a `queries` array field for
     * subqueries.
     *
     * Note that, while this can become complicated to do by hand for complex or
     * deeply nested queries, it provides a formalized expression tree API for
     * external libraries that implement a parser for custom query languages.
     *
     * @param query  Search query
     * @param searchOptions  Search options. Each option, if not given, defaults to the corresponding value of `searchOptions` given to the constructor, or to the library default.
     */search(t,e={}){const{searchOptions:s}=this._options;const n={...s,...e};const i=this.executeQuery(t,e);const o=[];for(const[t,{score:e,terms:s,match:r}]of i){const i=s.length||1;const c={id:this._documentIds.get(t),score:e*i,terms:Object.keys(r),queryTerms:s,match:r};Object.assign(c,this._storedFields.get(t));(n.filter==null||n.filter(c))&&o.push(c)}if(t===MiniSearch.wildcard&&n.boostDocument==null)return o;o.sort(V);return o}
/**
     * Provide suggestions for the given search query
     *
     * The result is a list of suggested modified search queries, derived from the
     * given search query, each with a relevance score, sorted by descending score.
     *
     * By default, it uses the same options used for search, except that by
     * default it performs prefix search on the last term of the query, and
     * combine terms with `'AND'` (requiring all query terms to match). Custom
     * options can be passed as a second argument. Defaults can be changed upon
     * calling the {@link MiniSearch} constructor, by passing a
     * `autoSuggestOptions` option.
     *
     * ### Basic usage:
     *
     * ```javascript
     * // Get suggestions for 'neuro':
     * miniSearch.autoSuggest('neuro')
     * // => [ { suggestion: 'neuromancer', terms: [ 'neuromancer' ], score: 0.46240 } ]
     * ```
     *
     * ### Multiple words:
     *
     * ```javascript
     * // Get suggestions for 'zen ar':
     * miniSearch.autoSuggest('zen ar')
     * // => [
     * //  { suggestion: 'zen archery art', terms: [ 'zen', 'archery', 'art' ], score: 1.73332 },
     * //  { suggestion: 'zen art', terms: [ 'zen', 'art' ], score: 1.21313 }
     * // ]
     * ```
     *
     * ### Fuzzy suggestions:
     *
     * ```javascript
     * // Correct spelling mistakes using fuzzy search:
     * miniSearch.autoSuggest('neromancer', { fuzzy: 0.2 })
     * // => [ { suggestion: 'neuromancer', terms: [ 'neuromancer' ], score: 1.03998 } ]
     * ```
     *
     * ### Filtering:
     *
     * ```javascript
     * // Get suggestions for 'zen ar', but only within the 'fiction' category
     * // (assuming that 'category' is a stored field):
     * miniSearch.autoSuggest('zen ar', {
     *   filter: (result) => result.category === 'fiction'
     * })
     * // => [
     * //  { suggestion: 'zen archery art', terms: [ 'zen', 'archery', 'art' ], score: 1.73332 },
     * //  { suggestion: 'zen art', terms: [ 'zen', 'art' ], score: 1.21313 }
     * // ]
     * ```
     *
     * @param queryString  Query string to be expanded into suggestions
     * @param options  Search options. The supported options and default values
     * are the same as for the {@link MiniSearch#search} method, except that by
     * default prefix search is performed on the last term in the query, and terms
     * are combined with `'AND'`.
     * @return  A sorted array of suggestions sorted by relevance score.
     */autoSuggest(t,e={}){e={...this._options.autoSuggestOptions,...e};const s=new Map;for(const{score:n,terms:i}of this.search(t,e)){const t=i.join(" ");const e=s.get(t);if(e!=null){e.score+=n;e.count+=1}else s.set(t,{score:n,terms:i,count:1})}const n=[];for(const[t,{score:e,terms:i,count:o}]of s)n.push({suggestion:t,terms:i,score:e/o});n.sort(V);return n}get documentCount(){return this._documentCount}get termCount(){return this._index.size}
/**
     * Deserializes a JSON index (serialized with `JSON.stringify(miniSearch)`)
     * and instantiates a MiniSearch instance. It should be given the same options
     * originally used when serializing the index.
     *
     * ### Usage:
     *
     * ```javascript
     * // If the index was serialized with:
     * let miniSearch = new MiniSearch({ fields: ['title', 'text'] })
     * miniSearch.addAll(documents)
     *
     * const json = JSON.stringify(miniSearch)
     * // It can later be deserialized like this:
     * miniSearch = MiniSearch.loadJSON(json, { fields: ['title', 'text'] })
     * ```
     *
     * @param json  JSON-serialized index
     * @param options  configuration options, same as the constructor
     * @return An instance of MiniSearch deserialized from the given JSON.
     */static loadJSON(t,e){if(e==null)throw new Error("MiniSearch: loadJSON should be given the same options used when serializing the index");return this.loadJS(JSON.parse(t),e)}
/**
     * Async equivalent of {@link MiniSearch.loadJSON}
     *
     * This function is an alternative to {@link MiniSearch.loadJSON} that returns
     * a promise, and loads the index in batches, leaving pauses between them to avoid
     * blocking the main thread. It tends to be slower than the synchronous
     * version, but does not block the main thread, so it can be a better choice
     * when deserializing very large indexes.
     *
     * @param json  JSON-serialized index
     * @param options  configuration options, same as the constructor
     * @return A Promise that will resolve to an instance of MiniSearch deserialized from the given JSON.
     */static async loadJSONAsync(t,e){if(e==null)throw new Error("MiniSearch: loadJSON should be given the same options used when serializing the index");return this.loadJSAsync(JSON.parse(t),e)}
/**
     * Returns the default value of an option. It will throw an error if no option
     * with the given name exists.
     *
     * @param optionName  Name of the option
     * @return The default value of the given option
     *
     * ### Usage:
     *
     * ```javascript
     * // Get default tokenizer
     * MiniSearch.getDefault('tokenize')
     *
     * // Get default term processor
     * MiniSearch.getDefault('processTerm')
     *
     * // Unknown options will throw an error
     * MiniSearch.getDefault('notExisting')
     * // => throws 'MiniSearch: unknown option "notExisting"'
     * ```
     */static getDefault(t){if(b.hasOwnProperty(t))return p(b,t);throw new Error(`MiniSearch: unknown option "${t}"`)}static loadJS(t,e){const{index:s,documentIds:n,fieldLength:i,storedFields:o,serializationVersion:r}=t;const c=this.instantiateMiniSearch(t,e);c._documentIds=T(n);c._fieldLength=T(i);c._storedFields=T(o);for(const[t,e]of c._documentIds)c._idToShortId.set(e,t);for(const[t,e]of s){const s=new Map;for(const t of Object.keys(e)){let n=e[t];r===1&&(n=n.ds);s.set(parseInt(t,10),T(n))}c._index.set(t,s)}return c}static async loadJSAsync(t,e){const{index:s,documentIds:n,fieldLength:i,storedFields:o,serializationVersion:r}=t;const c=this.instantiateMiniSearch(t,e);c._documentIds=await L(n);c._fieldLength=await L(i);c._storedFields=await L(o);for(const[t,e]of c._documentIds)c._idToShortId.set(e,t);let h=0;for(const[t,e]of s){const s=new Map;for(const t of Object.keys(e)){let n=e[t];r===1&&(n=n.ds);s.set(parseInt(t,10),await L(n))}++h%1e3===0&&await E(0);c._index.set(t,s)}return c}static instantiateMiniSearch(t,e){const{documentCount:s,nextId:n,fieldIds:i,averageFieldLength:o,dirtCount:r,serializationVersion:c}=t;if(c!==1&&c!==2)throw new Error("MiniSearch: cannot deserialize an index created with an incompatible version");const h=new MiniSearch(e);h._documentCount=s;h._nextId=n;h._idToShortId=new Map;h._fieldIds=i;h._avgFieldLength=o;h._dirtCount=r||0;h._index=new SearchableMap;return h}executeQuery(t,e={}){if(t===MiniSearch.wildcard)return this.executeWildcardQuery(e);if(typeof t!=="string"){const s={...e,...t,queries:void 0};const n=t.queries.map((t=>this.executeQuery(t,s)));return this.combineResults(n,s.combineWith)}const{tokenize:s,processTerm:n,searchOptions:i}=this._options;const o={tokenize:s,processTerm:n,...i,...e};const{tokenize:r,processTerm:c}=o;const h=r(t).flatMap((t=>c(t))).filter((t=>!!t));const u=h.map(S(o));const d=u.map((t=>this.executeQuerySpec(t,o)));return this.combineResults(d,o.combineWith)}executeQuerySpec(t,e){const s={...this._options.searchOptions,...e};const n=(s.fields||this._options.fields).reduce(((t,e)=>({...t,[e]:p(s.boost,e)||1})),{});const{boostDocument:i,weights:o,maxFuzzy:r,bm25:c}=s;const{fuzzy:h,prefix:u}={...x.weights,...o};const d=this._index.get(t.term);const a=this.termResults(t.term,t.term,1,t.termBoost,d,n,i,c);let l;let f;t.prefix&&(l=this._index.atPrefix(t.term));if(t.fuzzy){const e=t.fuzzy===true?.2:t.fuzzy;const s=e<1?Math.min(r,Math.round(t.term.length*e)):e;s&&(f=this._index.fuzzyGet(t.term,s))}if(l)for(const[e,s]of l){const o=e.length-t.term.length;if(!o)continue;f===null||f===void 0?void 0:f.delete(e);const r=u*e.length/(e.length+.3*o);this.termResults(t.term,e,r,t.termBoost,s,n,i,c,a)}if(f)for(const e of f.keys()){const[s,o]=f.get(e);if(!o)continue;const r=h*e.length/(e.length+o);this.termResults(t.term,e,r,t.termBoost,s,n,i,c,a)}return a}executeWildcardQuery(t){const e=new Map;const s={...this._options.searchOptions,...t};for(const[t,n]of this._documentIds){const i=s.boostDocument?s.boostDocument(n,"",this._storedFields.get(t)):1;e.set(t,{score:i,terms:[],match:{}})}return e}combineResults(t,e=m){if(t.length===0)return new Map;const s=e.toLowerCase();const n=w[s];if(!n)throw new Error(`Invalid combination operator: ${e}`);return t.reduce(n)||new Map}toJSON(){const t=[];for(const[e,s]of this._index){const n={};for(const[t,e]of s)n[t]=Object.fromEntries(e);t.push([e,n])}return{documentCount:this._documentCount,nextId:this._nextId,documentIds:Object.fromEntries(this._documentIds),fieldIds:this._fieldIds,fieldLength:Object.fromEntries(this._fieldLength),averageFieldLength:this._avgFieldLength,storedFields:Object.fromEntries(this._storedFields),dirtCount:this._dirtCount,index:t,serializationVersion:2}}termResults(t,e,s,n,i,o,r,c,h=new Map){if(i==null)return h;for(const u of Object.keys(o)){const d=o[u];const a=this._fieldIds[u];const l=i.get(a);if(l==null)continue;let f=l.size;const m=this._avgFieldLength[a];for(const i of l.keys()){if(!this._documentIds.has(i)){this.removeTerm(a,i,e);f-=1;continue}const o=r?r(this._documentIds.get(i),e,this._storedFields.get(i)):1;if(!o)continue;const _=l.get(i);const g=this._fieldLength.get(i)[a];const w=v(_,f,this._documentCount,g,m,c);const y=s*n*d*o*w;const S=h.get(i);if(S){S.score+=y;k(S.terms,t);const s=p(S.match,e);s?s.push(u):S.match[e]=[u]}else h.set(i,{score:y,terms:[t],match:{[e]:[u]}})}}return h}addTerm(t,e,s){const n=this._index.fetch(s,O);let i=n.get(t);if(i==null){i=new Map;i.set(e,1);n.set(t,i)}else{const t=i.get(e);i.set(e,(t||0)+1)}}removeTerm(t,e,s){if(!this._index.has(s)){this.warnDocumentChanged(e,t,s);return}const n=this._index.fetch(s,O);const i=n.get(t);i==null||i.get(e)==null?this.warnDocumentChanged(e,t,s):i.get(e)<=1?i.size<=1?n.delete(t):i.delete(e):i.set(e,i.get(e)-1);this._index.get(s).size===0&&this._index.delete(s)}warnDocumentChanged(t,e,s){for(const n of Object.keys(this._fieldIds))if(this._fieldIds[n]===e){this._options.logger("warn",`MiniSearch: document with ID ${this._documentIds.get(t)} has changed before removal: term "${s}" was not present in field "${n}". Removing a document after it has changed can corrupt the index!`,"version_conflict");return}}addDocumentId(t){const e=this._nextId;this._idToShortId.set(t,e);this._documentIds.set(e,t);this._documentCount+=1;this._nextId+=1;return e}addFields(t){for(let e=0;e<t.length;e++)this._fieldIds[t[e]]=e}addFieldLength(t,e,s,n){let i=this._fieldLength.get(t);i==null&&this._fieldLength.set(t,i=[]);i[e]=n;const o=this._avgFieldLength[e]||0;const r=o*s+n;this._avgFieldLength[e]=r/(s+1)}removeFieldLength(t,e,s,n){if(s===1){this._avgFieldLength[e]=0;return}const i=this._avgFieldLength[e]*s-n;this._avgFieldLength[e]=i/(s-1)}saveStoredFields(t,e){const{storeFields:s,extractField:n}=this._options;if(s==null||s.length===0)return;let i=this._storedFields.get(t);i==null&&this._storedFields.set(t,i={});for(const t of s){const s=n(e,t);s!==void 0&&(i[t]=s)}}}MiniSearch.wildcard=Symbol("*");const p=(t,e)=>Object.prototype.hasOwnProperty.call(t,e)?t[e]:void 0;const w={[m]:(t,e)=>{for(const s of e.keys()){const n=t.get(s);if(n==null)t.set(s,e.get(s));else{const{score:t,terms:i,match:o}=e.get(s);n.score=n.score+t;n.match=Object.assign(n.match,o);C(n.terms,i)}}return t},[_]:(t,e)=>{const s=new Map;for(const n of e.keys()){const i=t.get(n);if(i==null)continue;const{score:o,terms:r,match:c}=e.get(n);C(i.terms,r);s.set(n,{score:i.score+o,terms:i.terms,match:Object.assign(i.match,c)})}return s},[g]:(t,e)=>{for(const s of e.keys())t.delete(s);return t}};const y={k:1.2,b:.7,d:.5};const v=(t,e,s,n,i,o)=>{const{k:r,b:c,d:h}=o;const u=Math.log(1+(s-e+.5)/(e+.5));return u*(h+t*(r+1)/(t+r*(1-c+c*n/i)))};const S=t=>(e,s,n)=>{const i=typeof t.fuzzy==="function"?t.fuzzy(e,s,n):t.fuzzy||false;const o=typeof t.prefix==="function"?t.prefix(e,s,n):t.prefix===true;const r=typeof t.boostTerm==="function"?t.boostTerm(e,s,n):1;return{term:e,fuzzy:i,prefix:o,termBoost:r}};const b={idField:"id",extractField:(t,e)=>t[e],stringifyField:(t,e)=>t.toString(),tokenize:t=>t.split(D),processTerm:t=>t.toLowerCase(),fields:void 0,searchOptions:void 0,storeFields:[],logger:(t,e)=>{typeof(console===null||console===void 0?void 0:console[t])==="function"&&console[t](e)},autoVacuum:true};const x={combineWith:m,prefix:false,fuzzy:false,maxFuzzy:6,boost:{},weights:{fuzzy:.45,prefix:.375},bm25:y};const z={combineWith:_,prefix:(t,e,s)=>e===s.length-1};const I={batchSize:1e3,batchWait:10};const M={minDirtFactor:.1,minDirtCount:20};const F={...I,...M};const k=(t,e)=>{t.includes(e)||t.push(e)};const C=(t,e)=>{for(const s of e)t.includes(s)||t.push(s)};const V=({score:t},{score:e})=>e-t;const O=()=>new Map;const T=t=>{const e=new Map;for(const s of Object.keys(t))e.set(parseInt(s,10),t[s]);return e};const L=async t=>{const e=new Map;let s=0;for(const n of Object.keys(t)){e.set(parseInt(n,10),t[n]);++s%1e3===0&&await E(0)}return e};const E=t=>new Promise((e=>setTimeout(e,t)));const D=/[\n\r\p{Z}\p{P}]+/u;export{MiniSearch as default};

