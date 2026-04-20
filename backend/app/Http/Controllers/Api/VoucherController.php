<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Voucher;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VoucherController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $vouchers = Voucher::query()
            ->where('user_id', $request->user()->id)
            ->orderByDesc('id')
            ->get();

        return response()->json(['data' => $vouchers]);
    }

    public function show(Request $request, Voucher $voucher): JsonResponse
    {
        $this->ensureOwnership($request, $voucher);

        return response()->json([
            'data' => $voucher,
            'qr_value' => $voucher->code,
            'watermark' => $voucher->status === 'pending'
                ? 'PENDING — Submit review untuk mengaktifkan'
                : null,
        ]);
    }

    public function submitReview(Request $request, Voucher $voucher): JsonResponse
    {
        $this->ensureOwnership($request, $voucher);

        $validated = $request->validate([
            'score' => ['required', 'integer', 'between:1,5'],
            'comment' => ['nullable', 'string', 'max:1000'],
        ]);

        $voucher->update([
            'status' => 'active',
            'review_score' => $validated['score'],
            'review_comment' => $validated['comment'] ?? null,
            'activated_at' => CarbonImmutable::now(),
        ]);

        return response()->json([
            'message' => 'Voucher berhasil diaktifkan.',
            'data' => $voucher->fresh(),
        ]);
    }

    public function redeem(Request $request, Voucher $voucher): JsonResponse
    {
        $this->ensureOwnership($request, $voucher);

        if ($voucher->status !== 'active') {
            return response()->json([
                'message' => 'Voucher belum aktif.',
            ], 422);
        }

        $voucher->update([
            'status' => 'redeemed',
            'redeemed_at' => CarbonImmutable::now(),
        ]);

        return response()->json([
            'message' => 'Voucher berhasil diredeem.',
            'data' => $voucher->fresh(),
        ]);
    }

    private function ensureOwnership(Request $request, Voucher $voucher): void
    {
        abort_unless($voucher->user_id === $request->user()->id, 403);
    }
}
