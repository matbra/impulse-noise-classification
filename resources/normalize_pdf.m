function pdf_normalized = normalize_pdf(pdf_unnormalized, x_axis)

delta_x = x_axis(2) - x_axis(1);  % assume uniformly spaced x axis

pdf_normalized = pdf_unnormalized / (sum(pdf_unnormalized)) / delta_x;

end
