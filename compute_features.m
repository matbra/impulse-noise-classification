function st_features = compute_features(x_a)

% normalize the declick signal
sigma_x_a = trimvar(x_a, 5);
x_a = x_a ./ sigma_x_a;

st_features.peak2rms = peak2rms(x_a);
st_features.kurtosis = kurtosis(x_a);

end