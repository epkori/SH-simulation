function [n, m] = noll2nm(j)
    n = floor((sqrt(8*j-7)-1)/2);
    m_val = j - n*(n+1)/2 - 1;
    if mod(n, 2) == 0
        m = 2 * floor(m_val/2);
    else
        m = 2 * floor((m_val+1)/2) - 1;
    end
    if mod(j, 2) ~= 0 && m ~= 0
        m = -m;
    end
end
