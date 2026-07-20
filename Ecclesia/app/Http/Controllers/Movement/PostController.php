<?php

declare(strict_types=1);

namespace App\Http\Controllers\Movement;

use App\Http\Controllers\Controller;
use App\Models\Movement;
use App\Models\MovementPost;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class PostController extends Controller
{
    public function index(Request $request): View
    {
        $posts = $this->movement($request)->posts()->latest('published_at')->latest()->paginate(12);

        return view('movement.posts.index', compact('posts'));
    }

    public function create(): View
    {
        return view('movement.posts.create', ['post' => new MovementPost(['published_at' => now()])]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);
        $data['image'] = $request->hasFile('image') ? $request->file('image')->store('movement-posts', 'public') : null;

        $this->movement($request)->posts()->create($data);

        return redirect()->route('mouvement.posts.index')->with('success', 'Annonce publiée.');
    }

    public function edit(Request $request, MovementPost $post): View
    {
        $this->authorizeOwnership($request, $post);

        return view('movement.posts.edit', compact('post'));
    }

    public function update(Request $request, MovementPost $post): RedirectResponse
    {
        $this->authorizeOwnership($request, $post);
        $data = $this->validated($request);

        if ($request->hasFile('image')) {
            if ($post->image) {
                Storage::disk('public')->delete($post->image);
            }
            $data['image'] = $request->file('image')->store('movement-posts', 'public');
        }

        $post->update($data);

        return redirect()->route('mouvement.posts.index')->with('success', 'Annonce mise à jour.');
    }

    public function destroy(Request $request, MovementPost $post): RedirectResponse
    {
        $this->authorizeOwnership($request, $post);
        if ($post->image) {
            Storage::disk('public')->delete($post->image);
        }
        $post->delete();

        return redirect()->route('mouvement.posts.index')->with('success', 'Annonce supprimée.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'body' => ['required', 'string'],
            'image' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:2048'],
            'video_url' => ['nullable', 'url', 'max:2048'],
            'published_at' => ['nullable', 'date'],
        ]);
    }

    private function movement(Request $request): Movement
    {
        return Movement::findOrFail($request->user()->movement_id);
    }

    private function authorizeOwnership(Request $request, MovementPost $post): void
    {
        abort_unless($post->movement_id === $request->user()->movement_id, 403);
    }
}
