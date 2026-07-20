@extends('movement.layouts.app')
@section('title', 'Documents')
@section('heading', 'Documents du mouvement')
@section('content')
    <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <form method="POST" enctype="multipart/form-data" action="{{ route('mouvement.documents.store') }}" class="card card-pad space-y-4 lg:col-span-1">
            @csrf
            <h3 class="text-base font-bold">Ajouter un document</h3>
            <div>
                <label class="field-label" for="title">Titre <span class="text-red-500">*</span></label>
                <input id="title" name="title" type="text" value="{{ old('title') }}" class="input" required>
                @error('title') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="file">Fichier <span class="text-red-500">*</span></label>
                <input id="file" name="file" type="file" required class="block w-full text-sm text-[color:var(--color-ink-soft)] file:mr-3 file:rounded-lg file:border-0 file:bg-[color:var(--color-navy)] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white">
                <p class="field-hint">PDF, Word, Excel, image — 10 Mo max.</p>
                @error('file') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <button type="submit" class="btn-primary w-full"><x-icon name="plus" class="h-4 w-4" /> Ajouter</button>
        </form>

        <div class="lg:col-span-2">
            <div class="card">
                <div class="border-b border-[color:var(--color-border-soft)] px-5 py-4"><h3 class="text-base font-bold">Documents ({{ $documents->count() }})</h3></div>
                @forelse($documents as $doc)
                    <div class="flex items-center gap-3 border-b border-[color:var(--color-border-soft)] px-5 py-3.5">
                        <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-[color:var(--color-navy)]/10 text-[color:var(--color-navy)]"><x-icon name="book" class="h-5 w-5" /></span>
                        <div class="min-w-0 flex-1">
                            <p class="truncate font-semibold text-[color:var(--color-ink)]">{{ $doc->title }}</p>
                            <p class="text-xs text-[color:var(--color-ink-soft)]">{{ $doc->humanSize() }} · {{ $doc->created_at->translatedFormat('d M Y') }}</p>
                        </div>
                        <a href="{{ \Illuminate\Support\Facades\Storage::url($doc->file_path) }}" target="_blank" class="btn-outline btn-sm"><x-icon name="eye" class="h-4 w-4" /> Ouvrir</a>
                        <form method="POST" action="{{ route('mouvement.documents.destroy', $doc) }}" onsubmit="return confirm('Supprimer ce document ?');">@csrf @method('DELETE')<button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50"><x-icon name="trash" class="h-4 w-4" /></button></form>
                    </div>
                @empty
                    <p class="px-5 py-10 text-center text-sm text-[color:var(--color-ink-soft)]">Aucun document.</p>
                @endforelse
            </div>
        </div>
    </div>
@endsection
