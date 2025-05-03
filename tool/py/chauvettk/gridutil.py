def find_grid_dimensions(n, aspect_ratio):
    w, h = aspect_ratio
    target_ratio = w / h
    best_pair = None
    min_diff = float('inf')

    # Find factor pairs
    for r in range(1, int(n**0.5) + 1):
        c = n // r
        ratio = c / r
        diff = abs(ratio - target_ratio)
        if diff < min_diff:
            min_diff = diff
            best_pair = (r, c)

    return best_pair  # (rows, columns)
