
describe windows_feature('Web-Server') do
  it { should be_installed }
end

describe windows_feature('Web-CertProvider') do
  it { should be_installed }
end

describe package('Microsoft Application Request Routing 3.0') do
  it { should be_installed }
end
