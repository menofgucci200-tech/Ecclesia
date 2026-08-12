<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\PaymentStatus;
use App\Enums\PaymentType;
use App\Http\Controllers\Controller;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PaymentController extends Controller
{
    public function index(Request $request): View
    {
        $parishId = $request->user()->managedParishId();
        $type = $request->string('type')->toString();
        $status = $request->string('status')->toString();

        $payments = Payment::with(['user', 'parish', 'massIntention'])
            ->when($parishId !== null, fn ($q) => $q->where('parish_id', $parishId))
            ->when($type !== '', fn ($q) => $q->where('type', $type))
            ->when($status !== '', fn ($q) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        $totalCollected = (int) Payment::query()
            ->where('status', PaymentStatus::Paid->value)
            ->when($parishId !== null, fn ($q) => $q->where('parish_id', $parishId))
            ->sum('amount');

        $paidCount = Payment::query()
            ->where('status', PaymentStatus::Paid->value)
            ->when($parishId !== null, fn ($q) => $q->where('parish_id', $parishId))
            ->count();

        return view('admin.payments.index', [
            'payments' => $payments,
            'totalCollected' => $totalCollected,
            'paidCount' => $paidCount,
            'types' => PaymentType::cases(),
            'statuses' => PaymentStatus::cases(),
            'type' => $type,
            'status' => $status,
        ]);
    }
}
