<?php

declare(strict_types=1);

namespace App\Http\Controllers\Movement;

use App\Http\Controllers\Controller;
use App\Models\Movement;
use Illuminate\Http\Request;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(Request $request): View
    {
        $movement = Movement::query()
            ->withCount(['members', 'posts', 'documents'])
            ->with('parish:id,name')
            ->findOrFail($request->user()->movement_id);

        $recentPosts = $movement->posts()->latest('published_at')->limit(5)->get();

        return view('movement.dashboard', compact('movement', 'recentPosts'));
    }
}
