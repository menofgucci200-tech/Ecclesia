<?php

declare(strict_types=1);

namespace App\Http\Controllers\Movement;

use App\Http\Controllers\Controller;
use App\Models\Movement;
use App\Models\MovementDocument;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class DocumentController extends Controller
{
    public function index(Request $request): View
    {
        $movement = $this->movement($request);
        $documents = $movement->documents()->latest()->get();

        return view('movement.documents.index', compact('movement', 'documents'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'file' => ['required', 'file', 'mimes:pdf,doc,docx,jpg,jpeg,png,webp,xls,xlsx', 'max:10240'],
        ]);

        $file = $request->file('file');
        $path = $file->store('movement-documents', 'public');

        $this->movement($request)->documents()->create([
            'title' => $validated['title'],
            'file_path' => $path,
            'mime' => $file->getClientMimeType(),
            'size' => $file->getSize(),
        ]);

        return back()->with('success', 'Document ajouté.');
    }

    public function destroy(Request $request, MovementDocument $document): RedirectResponse
    {
        abort_unless($document->movement_id === $request->user()->movement_id, 403);

        Storage::disk('public')->delete($document->file_path);
        $document->delete();

        return back()->with('success', 'Document supprimé.');
    }

    private function movement(Request $request): Movement
    {
        return Movement::findOrFail($request->user()->movement_id);
    }
}
