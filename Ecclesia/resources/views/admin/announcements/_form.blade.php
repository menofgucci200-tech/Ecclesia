@php
    /** @var \App\Models\Announcement $announcement */
    $isEdit = $announcement->exists;
    $publishedValue = old('published_at', optional($announcement->published_at)->format('Y-m-d\TH:i'));
@endphp

<form method="POST" action="{{ $isEdit ? admin_route('announcements.update', $announcement) : admin_route('announcements.store') }}" class="grid grid-cols-1 gap-6 lg:grid-cols-3">
    @csrf
    @if($isEdit) @method('PUT') @endif

    {{-- Main column --}}
    <div class="space-y-6 lg:col-span-2">
        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Contenu</h3>
            <div class="space-y-5">
                <div>
                    <label class="field-label" for="title">Titre <span class="text-red-500">*</span></label>
                    <input id="title" name="title" type="text" value="{{ old('title', $announcement->title) }}" class="input" required>
                    @error('title') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="body">Message <span class="text-red-500">*</span></label>
                    <textarea id="body" name="body" class="textarea" rows="8" required>{{ old('body', $announcement->body) }}</textarea>
                    @error('body') <p class="field-error">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Médias (optionnel)</h3>
            <div class="space-y-5">
                <div>
                    <label class="field-label" for="image_url">URL de l'image</label>
                    <input id="image_url" name="image_url" type="url" value="{{ old('image_url', $announcement->image_url) }}" class="input" placeholder="https://…">
                    @error('image_url') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="video_url">URL de la vidéo</label>
                    <input id="video_url" name="video_url" type="url" value="{{ old('video_url', $announcement->video_url) }}" class="input" placeholder="https://…">
                    @error('video_url') <p class="field-error">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>
    </div>

    {{-- Sidebar column --}}
    <div class="space-y-6">
        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Diffusion</h3>
            <div class="space-y-5">
                @if($scopeParish)
                    <div>
                        <span class="field-label">Paroisse</span>
                        <div class="flex items-center gap-2 rounded-xl bg-[color:var(--color-surface-muted)] px-3.5 py-2.5 text-sm">
                            <x-icon name="church" class="h-5 w-5 text-[color:var(--color-navy)]" />
                            <span class="font-medium">{{ $scopeParish->name }}</span>
                        </div>
                    </div>
                @else
                    <div>
                        <label class="field-label" for="parish_id">Paroisse <span class="text-red-500">*</span></label>
                        <select id="parish_id" name="parish_id" class="select" required>
                            <option value="">— Choisir —</option>
                            @foreach($parishes as $p)
                                <option value="{{ $p->id }}" @selected((string) old('parish_id', $announcement->parish_id) === (string) $p->id)>{{ $p->name }}</option>
                            @endforeach
                        </select>
                        @error('parish_id') <p class="field-error">{{ $message }}</p> @enderror
                    </div>
                @endif

                <div>
                    <label class="field-label" for="category">Catégorie <span class="text-red-500">*</span></label>
                    <select id="category" name="category" class="select" required>
                        @foreach($categories as $c)
                            <option value="{{ $c->value }}" @selected(old('category', $announcement->category?->value) === $c->value)>{{ $c->label() }}</option>
                        @endforeach
                    </select>
                    @error('category') <p class="field-error">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="field-label" for="published_at">Date de publication</label>
                    <input id="published_at" name="published_at" type="datetime-local" value="{{ $publishedValue }}" class="input">
                    <p class="field-hint">Laisser vide pour un brouillon. Une date à venir programme la publication.</p>
                    @error('published_at') <p class="field-error">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Auteur & options</h3>
            <div class="space-y-5">
                <div>
                    <label class="field-label" for="author_name">Nom de l'auteur <span class="text-red-500">*</span></label>
                    <input id="author_name" name="author_name" type="text" value="{{ old('author_name', $announcement->author_name) }}" class="input" required>
                    @error('author_name') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="author_role">Fonction</label>
                    <input id="author_role" name="author_role" type="text" value="{{ old('author_role', $announcement->author_role) }}" class="input" placeholder="Curé, Secrétariat…">
                    @error('author_role') <p class="field-error">{{ $message }}</p> @enderror
                </div>

                <label class="flex items-center gap-3 rounded-xl border border-[color:var(--color-border-soft)] px-3.5 py-3 text-sm">
                    <input type="hidden" name="is_pinned" value="0">
                    <input type="checkbox" name="is_pinned" value="1" @checked(old('is_pinned', $announcement->is_pinned)) class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]">
                    <span><span class="font-medium">Épingler</span> en haut du fil</span>
                </label>
                <label class="flex items-center gap-3 rounded-xl border border-[color:var(--color-border-soft)] px-3.5 py-3 text-sm">
                    <input type="hidden" name="is_important" value="0">
                    <input type="checkbox" name="is_important" value="1" @checked(old('is_important', $announcement->is_important)) class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-danger)]">
                    <span><span class="font-medium">Marquer importante</span></span>
                </label>
            </div>
        </div>

        <div class="flex items-center justify-end gap-3">
            <a href="{{ admin_route('announcements.index') }}" class="btn-ghost">Annuler</a>
            <button type="submit" class="btn-primary">
                <x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Publier' }}
            </button>
        </div>
    </div>
</form>
