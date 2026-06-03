
function Z = zernike_polynomial(n, m, rho, theta)
    m_abs = abs(m);
    R = zeros(size(rho));
    for s = 0:((n-m_abs)/2)
        num = (-1)^s * factorial(n-s);
        den = factorial(s) * factorial((n+m_abs)/2 - s) * factorial((n-m_abs)/2 - s);
        R = R + (num/den) * rho.^(n-2*s);
    end
    
    if m > 0
        Z = sqrt(2*(n+1)) * R .* cos(m * theta);
    elseif m < 0
        Z = sqrt(2*(n+1)) * R .* sin(m_abs * theta);
    else
        Z = sqrt(n+1) * R;
    end
end