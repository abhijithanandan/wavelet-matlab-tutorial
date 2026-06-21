% run_tests.m  Run every unit test; raise an error if any fail.
%   Run from the repo root:  octave --no-gui -q tests/run_tests.m
addpath('common'); addpath('tutorial'); addpath('matlab'); addpath('tools'); addpath('tests');
tests = {@test_pinv_classify, @test_haar_dwt, @test_scatter_features, ...
         @test_make_texture_subset, @test_tutorial_accuracy, ...
         @test_haar_reference, @test_wscat_features};
nfail = 0;
for i = 1:numel(tests)
  name = func2str(tests{i});
  try
    tests{i}();
    fprintf('ok   - %s\n', name);
  catch e
    nfail = nfail + 1;
    fprintf('FAIL - %s: %s\n', name, e.message);
  end
end
if nfail > 0, error('%d test(s) failed', nfail); end
fprintf('All %d tests passed.\n', numel(tests));
