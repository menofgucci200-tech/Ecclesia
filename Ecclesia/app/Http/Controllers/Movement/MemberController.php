<?php

declare(strict_types=1);

namespace App\Http\Controllers\Movement;

use App\Http\Controllers\Controller;
use App\Models\Movement;
use Illuminate\Http\Request;
use Illuminate\View\View;

class MemberController extends Controller
{
    public function index(Request $request): View
    {
        $movement = Movement::findOrFail($request->user()->movement_id);

        $members = $movement->members()
            ->orderBy('first_name')
            ->paginate(20);

        return view('movement.members.index', compact('movement', 'members'));
    }
}
